import 'dart:collection';

import 'package:xterm/xterm.dart';
import 'package:zomboid_rcon/terminal/parsers.dart';
import 'package:zomboid_rcon/zomboid_server.dart';

class ZomboidRconReplBridge {
  late final void Function(String data) onOutput;
  late final ZomboidServer server;
  late final Terminal terminal;
  final RecentCommands recentCommands = RecentCommands();

  ZomboidRconReplBridge(this.onOutput, this.server, this.terminal) {
    onOutput('Welcome to xterm.dart!\r\n');
    onOutput('Type "help" for more information.\r\n');
    onOutput('\n');
    onOutput('\$ ');
  }

  void setServer(ZomboidServer setServer) => server = setServer;

  void write(String input) async {
    print("Input: $input");
    for (var char in input.codeUnits) {
      print("Char: $char");
      switch (char) {
        case 13: // carriage return
          bool res = await processCommand();
          if (!res) break;
          onOutput.call('\r\n');
          onOutput.call('\$ ');
          break;
        case 127: // backspace
          print(terminal.buffer.currentLine.toString());
          if (terminal.buffer.currentLine.toString() != '\$ ') onOutput.call('\b \b');
          break;
        case 68: // Left arrow TODO: allow if cursor has left buffer
        case 67: // Right arrow TODO: allow if cursor has right buffer
        case 65: // Up arrow
        case 66: // Down arrow
          break;
        default:
          onOutput.call(String.fromCharCode(char));
      }
    }
  }

  Future<bool> processCommand() async {
    String command = terminal.buffer.currentLine.toString().replaceFirst(RegExp(r'\$(\s+)?'), "");
    if (command == '') return false;
    print("command: $command");
    recentCommands.push(command);
    if (command == 'clear') {
      terminal.buffer.clear();
      terminal.buffer.setCursor(0, 0);
    } else {
      onOutput.call('\r\n');
      await parseCommandResults(command);
    }
    return true;
  }

  Future<void> parseCommandResults(String command) async {
    String results = await server.command(command);
    switch (command) {
      case 'help':
        HelpParser(terminal, results).parse(onOutput);
        break;
      default:
        onOutput.call(results);
    }
  }
}

class RecentCommands {
  int _cursor = 0;
  final int _maxLength = 10;
  final _stack = Queue<String>();

  int get length => _stack.length;

  bool canPop() => _stack.isNotEmpty;

  void clearStack(){
    while(_stack.isNotEmpty){
      _stack.removeLast();
    }
  }

  void push(String element) {
    if (length < _maxLength) {
      _stack.addLast(element);
      _cursor++;
    } else {
      _stack.removeFirst();
      _stack.addLast(element);
    }
  }

  String pop() {
    assert(
      length != 0,
      "Cannot pop from an empty recent command stack."
    );
    String lastElement = _stack.last;
    _stack.removeLast();
    _cursor--;
    return lastElement;
  }

  String peak(int? index) => index != null ? _stack.toList(growable: false)[index] : _stack.last;

}