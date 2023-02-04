import 'package:flutter/material.dart';
import 'package:zomboid_rcon/servers/pages/home.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Zomboid RCON',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const MyHomePage(title: 'Server List'),
    );
  }
}