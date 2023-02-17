import 'dart:async';
import 'dart:io';

import 'package:tuple/tuple.dart';
import 'package:xterm/xterm.dart';
import 'package:zomboid_rcon/database.dart';
import 'package:zomboid_rcon/terminal/constants.dart';
import 'package:zomboid_rcon/terminal/parsers.dart';
import 'package:zomboid_rcon/zomboid_server.dart';

typedef OutputStream = void Function(String data);

class ZomboidRconRepl {
  String prompt;
  final Server serverConfig;
  final Terminal terminal;
  late final RconSocket server;
  late final ZomboidRconReplBridge _adapter;
  bool isLoggedIn = false;

  final void Function() onExit;

  final _statusController = StreamController<String>();
  Stream<String> get stream => _statusController.stream;

  ZomboidRconRepl(
      {this.prompt = '',
        required this.serverConfig,
        required this.terminal,
        required this.onExit,
        maxHistory = 50}) {
    terminal.onOutput = write;
    commandHistory = CommandHistory(maxHistory: maxHistory);
  }

  late final CommandHistory commandHistory;

  Future<void> init() async {
    _statusController.sink.add('Connecting...');
    server = await ZomboidServer.connect(
        serverConfig.address,
        serverConfig.port,
    );
    _statusController.sink.add('Connected');
    _statusController.sink.add('Authenticating...');
    bool isAuthed = await server.authenticate(serverConfig.password);
    isAuthed ? _statusController.sink.add('Authenticated') : _statusController.sink.add('Failed to authenticate');
    _adapter = ZomboidRconReplBridge(repl: this);
    if (isAuthed) isLoggedIn = isAuthed;
  }

  void write(String input) async => _adapter.onInput(input);

  /// Kills and cleans up the REPL.
  FutureOr<void> exit() {
    _statusController.sink.add('Exiting...');
    if (isLoggedIn) _adapter.exit();
  }
}

class ZomboidRconReplBridge {
  final ZomboidRconRepl repl;

  Server get serverConfig => repl.serverConfig;
  RconSocket get server => repl.server;
  Terminal get terminal => repl.terminal;
  OutputStream get toTerminal => terminal.write;
  CommandHistory get commandHistory => repl.commandHistory;
  String get currentLineText => (terminal.buffer.currentLine.toString().trimRight().replaceFirst(repl.prompt, ''));
  int get currentLineLength => currentLineText.length;

  ZomboidRconReplBridge({required this.repl}) {
    toTerminal('Welcome to "${serverConfig.name}" on `${serverConfig.address}`!\r\n');
    toTerminal('Type "help" for more information.\r\n');
    toTerminal(repl.prompt);
  }

  void onInput(String input) async {
    if (input.isEmpty) return;
    List<int> inputCodeUnits = input.codeUnits;
    if (
      inputCodeUnits.length == 3 &&
      inputCodeUnits[0] == 27 &&
      inputCodeUnits[1] == 91
    ) {
      int lastCodeUnit = inputCodeUnits[2];
      switch (lastCodeUnit) {
        case KeyCodes.capitalA: // Up
        case KeyCodes.capitalB: // Down
          if (currentLineLength > 0) {
            int num = currentLineLength;
            while (num > 0) {
              toTerminal.call('\b \b');
              num--;
            }
          }
          processHistory(
              (lastCodeUnit == KeyCodes.capitalA) ?
                HistoryDirection.up : HistoryDirection.down
          );
          return;
        case KeyCodes.capitalD: // Left
        case KeyCodes.capitalC: // Right
          if (currentLineLength == 0) return;
          if (lastCodeUnit == KeyCodes.capitalC) {
            if ((terminal.buffer.cursorX + 1) > (currentLineLength + repl.prompt.length)) return;
          }
          if (lastCodeUnit == KeyCodes.capitalD) {
            if ((terminal.buffer.cursorX - 1) < repl.prompt.length) return;
          }
      }
    }
    for (var char in input.codeUnits) {
      switch (char) {
        case KeyCodes.backspace:
          if (terminal.buffer.currentLine.toString().trim() != repl.prompt && currentLineLength > 0) toTerminal.call('\b \b');
          break;
        case KeyCodes.etx:
          commandHistory.resetCursor();
          toTerminal.call('\r\n');
          toTerminal.call(repl.prompt);
          break;
        case KeyCodes.carriageReturn:
          String command = terminal.buffer.currentLine.toString().replaceFirst(RegExp(repl.prompt + r'(\s+)?'), "");
          bool res = await processCommand(command);
          commandHistory.resetCursor();
          if (!res) break;
          toTerminal.call('\r\n');
          toTerminal.call(repl.prompt);
          break;
        default:
          toTerminal.call(String.fromCharCode(char));
      }
    }
  }

  void resetCursor({Tuple2<int, int>? cursorVec}) {
    bool fullReset = (cursorVec == null);
    if (fullReset) {
      terminal.buffer.setCursor(0, 0);
    } else {
      terminal.buffer.setCursor(cursorVec.item1, cursorVec.item2);
    }
    terminal.write(repl.prompt);
  }

  void processHistory(HistoryDirection historyDirection) {
    String res = '';
    if (historyDirection == HistoryDirection.up) {
      res = commandHistory.up();
    } else {
      res = commandHistory.down();
    }
    terminal.write(res);
  }

  Future<bool> processCommand(String command) async {
    if (command == '') return false;
    commandHistory.push(command);
    if (command == ShellCommand.exit.name) {
      await repl.exit();
      repl.onExit();
      return false;
    } else if (command == ShellCommand.reset.name) {
      commandHistory.clearStack();
      terminal.buffer.clear();
      resetCursor();
      return false;
    } else if (command == ShellCommand.clear.name) {
      terminal.buffer.clear();
      resetCursor();
      return false;
    } else if (command == SpecialCommand.quit.name) {
      toTerminal.call('\r\nThis command will shut off the server, then exit.\r\n');
      sleep(const Duration(seconds: 2));
      await server.command(command); // Intentionally skip parsing, only execute raw command
      sleep(const Duration(seconds: 1));
      await repl.exit();
      repl.onExit();
      return false;
    } else {
      toTerminal.call('\r\n');
      await executeCommandThenParseResults(command);
    }
    return true;
  }

  Future<void> executeCommandThenParseResults(String command) async {
    String results = await server.command(command);
    switch (command.trim()) {
      case 'help':
        HelpParserRenderer(terminal, results).render();
        break;
      case 'showoptions':
        ShowOptionsParserRenderer(terminal, results).render();
        break;
      default:
        DefaultParserRenderer(terminal, results).render();
    }
  }

  exit() {
    if (repl.isLoggedIn) server.close();
  }
}

enum HistoryDirection {
  up, down,
}

class CommandHistory {
  int _cursor = -1;
  final int maxHistory;
  final List<String> _stack =[];

  CommandHistory({
    this.maxHistory = 50,
  });

  int get length => _stack.length;

  void resetCursor() => _cursor = -1;

  void clearStack(){
    while(_stack.isNotEmpty){
      _stack.removeLast();
    }
  }

  void push(String element) {
    if (length == maxHistory) {
      _stack.removeLast();
    }
    _stack.insert(0, element.trim());
  }

  String up() {
    if ((length - 1) >= (_cursor + 1)) _cursor++;
    if (_cursor == -1) return ''; // Looks unnecessary, but needed in case UP is pressed on first load.
    return _stack[_cursor];
  }

  String down() {
    if (_cursor > -1) _cursor--;
    if (_cursor == -1) return '';
    return _stack[_cursor];
  }
}