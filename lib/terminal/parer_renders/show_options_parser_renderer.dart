import 'dart:collection';
import 'dart:convert';

import 'base_parser_renderer.dart';

class ShowOptionsParserRenderer extends BaseParserRenderer {
  ShowOptionsParserRenderer(super.terminal, super.results);

  @override
  void render() {
    Queue<String> lines = splitLines;
    terminalOutput.call(lines.first);
    terminalOutput.call(lineSeparator);
    lines.removeFirst();
    _renderLines(Queue.from(lines.map((e) => _parseLine(e))));
  }

  void _renderLines(Queue<List<String>> lines) {
    for (final line in lines) {
      final String optionName = line[0];
      final String optionValue = line[1];
      terminal.setForegroundColor256(2);
      terminalOutput.call(" $optionName : ");
      terminal.setForegroundColor256(7);
      terminalOutput.call(optionValue);

      terminal.resetForeground();
      terminalOutput.call(lineSeparator);
    }
  }

  List<String> _parseLine(String line) {
    // First split the command name from the metadata.
    var keyAndValueRegex = RegExp(r'\* (\S+)=(.*)$');
    final Match commandParts = keyAndValueRegex.allMatches(line).first;
    final String optionName = commandParts.group(1)!;
    final String optionValue = commandParts.group(2)!;

    return [
      optionName,
      optionValue.isEmpty ? '<UNSET>' : '"$optionValue"',
    ];
  }
}