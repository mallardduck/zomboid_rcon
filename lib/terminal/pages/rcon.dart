import 'dart:async';
import 'dart:io';

import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xterm/xterm.dart';
import 'package:zomboid_rcon/database.dart';
import 'package:zomboid_rcon/terminal/zomboid_rcon_repl.dart';
import 'package:zomboid_rcon/zomboid_server.dart';

class RconPage extends StatefulWidget {
  const RconPage({super.key, required this.serverConfig});

  final Server serverConfig;

  @override
  State<StatefulWidget> createState() => _RconPageState();
}

class _RconPageState extends State<RconPage> {
  final terminal = Terminal(
    maxLines: 10000,
  );

  late final ZomboidRconRepl repl = ZomboidRconRepl(
    prompt: '>>>',
    serverConfig: widget.serverConfig,
    terminal: terminal,
    onExit: _onExitCalled,
  );
  late final Stream<String> _statusStream = repl.stream;
  final terminalController = TerminalController();

  bool _isConnected = false;

  bool _isError = false;
  Exception? _errorException;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.endOfFrame.then(
      (_) {
        if (mounted) _startRcon();
      },
    );
  }

  Future<void> _startRcon() async {
    try {
      await repl.init();
      setState(() {
        _isConnected = true;
      });
    } on Exception catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error connecting to server...')),
      );
      setState(() {
        _isConnected = false;
        _isError = true;
        _errorException = e;
      });
    }
  }

  void _onExitCalled() {
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackPressed,
        child: PlatformScaffold(
          appBar: PlatformAppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: PlatformText("Server: ${widget.serverConfig.name}"),
          ),
          body: SafeArea(
            child:  _isConnected ?
                      _buildTerminalView() :
                        _isError ?
                          _buildExceptionView() :
                          _buildConnectingView(),
          ),
        ),
    );
  }

  Future<bool> _onBackPressed() async {
    await repl.exit();
    return true;
  }

  TerminalView _buildTerminalView() {
    return TerminalView(
        terminal,
        controller: terminalController,
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.keyV, control: true):
            PasteTextIntent(SelectionChangedCause.keyboard),
        },
        autofocus: true,
        backgroundOpacity: 0.7,
        onSecondaryTapDown: (details, offset) async {
          final selection = terminalController.selection;
          if (selection != null) {
            final text = terminal.buffer.getText(selection);
            terminalController.clearSelection();
            await Clipboard.setData(ClipboardData(text: text));
          } else {
            final data = await Clipboard.getData('text/plain');
            final text = data?.text;
            if (text != null) {
              terminal.paste(text);
            }
          }
        },
      );
  }

  _buildExceptionView() {
    try {
      throw _errorException!;
    } on SocketException catch(e) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Error: ${e.message}'),
          Text('address = ${e.address?.address}, port = ${e.port}'),
        ],
      );
    } on RconAuthenticationException catch(e) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Error: ${e.message}'),
        ],
      );
    } on TimeoutException {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Error: Timeout while connecting to server.'),
        ],
      );
    }
  }

  _buildConnectingView() {
    return StreamBuilder<String>(
      stream: _statusStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('No status data yet');
        } else if (snapshot.connectionState == ConnectionState.done) {
          return const Text('Connected!');
        }
        return Text(snapshot.data ?? '');
      },
    );
  }
}