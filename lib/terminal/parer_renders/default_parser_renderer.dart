import 'base_parser_renderer.dart';

class DefaultParserRenderer extends BaseParserRenderer {
  DefaultParserRenderer(super.terminal, super.results);

  @override
  void render() {
    int count = splitLines.length;
    int index = 0;
    for (final line in splitLines) {
      terminalOutput.call(line);
      index++;
      if (index != count) terminalOutput.call(lineSeparator);
    }
  }
}