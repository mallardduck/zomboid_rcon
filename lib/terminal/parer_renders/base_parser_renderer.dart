import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:xterm/xterm.dart';
import 'package:zomboid_rcon/extensions.dart';

abstract class BaseParserRenderer {
  final String results;
  Terminal terminal;

  String get lineSeparator => Platform().lineSeparator;
  Function(String data) get terminalOutput => terminal.write;

  Queue<String> get splitLines {
    LineSplitter ls = const LineSplitter();
    return Queue<String>.from(ls.convert(results));
  }

  BaseParserRenderer(this.terminal, this.results);

  void render();
}