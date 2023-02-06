import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:xterm/xterm.dart';
import 'package:zomboid_rcon/extensions.dart';

class HelpParser {
  final String results;

  Terminal terminal;

  HelpParser(this.terminal, this.results);

  void parse(void Function(String data) terminalOutput) {
    LineSplitter ls = const LineSplitter();
    var lines = Queue<String>.from(ls.convert(results));
    terminalOutput.call(lines.first);
    terminalOutput.call(Platform().lineSeparator);
    lines.removeFirst();
    for (final line in lines) {
      final List<String> parsed = parseLine(line);
      final String commandName = parsed[0];
      final String commandDescription = parsed[1];
      final String commandUse = parsed[2];
      final String commandExample = parsed[3];
      terminal.setForegroundColor256(2);
      terminalOutput.call(" $commandName : ");
      terminal.setForegroundColor256(7);
      terminalOutput.call(commandDescription);
      if (commandUse.isNotEmpty) {
        terminalOutput.call(Platform().lineSeparator);
        terminal.setForegroundColor256(6);
        terminalOutput.call("    $commandUse");
      }
      if (commandExample.isNotEmpty) {
        terminalOutput.call(Platform().lineSeparator);
        terminal.setForegroundColor256(3);
        terminalOutput.call("    $commandExample");
      }
      terminal.resetForeground();
      terminalOutput.call(Platform().lineSeparator);
    }
  }

  List<String> parseLine(String line) {
    // First split the command name from the metadata.
    var commandAndExtra = RegExp(r'\* (\S+) : (.*)$');
    final Match commandParts = commandAndExtra.allMatches(line).first;
    final String commandName = commandParts.group(1)!;
    String commandDescription = commandParts.group(2)!;

    // Extract the Example subtext...
    var exampleRegex = RegExp(r'(.+)((For )?[e|E]x(ample)?:? .*)$');
    final Iterable<Match> exampleParts = exampleRegex.allMatches(commandDescription);
    String commandExample = '';
    if (exampleParts.isNotEmpty) {
      commandDescription = exampleParts.first.group(1)!;
      commandExample = exampleParts.first.group(2)!;
    }

    // Extract the Use subtext...
    var useRegex = RegExp(r'^(.*)(Use.*)$');
    final Iterable<Match> useParts = useRegex.allMatches(commandDescription);
    String commandUse = '';
    if (useParts.isNotEmpty) {
      commandDescription = useParts.first.group(1)!;
      commandUse = useParts.first.group(2)!;
    }

    return [
      commandName,
      commandDescription,
      commandUse,
      commandExample,
    ];
  }
}