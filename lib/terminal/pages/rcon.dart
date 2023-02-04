import 'package:flutter/material.dart';
import 'package:zomboid_rcon/servers/models/server.dart';

class RconPage extends StatelessWidget {
  final Server server;

  const RconPage({super.key, required this.server});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Server: ${server.name}"),
      ),
      body: const Text('Yeet'),
    );
  }
}