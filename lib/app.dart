import 'package:flutter/material.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zomboid_rcon/servers/pages/home.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final materialTheme = ThemeData(
      primarySwatch: Colors.orange,
    );
    final cupertinoTheme = MaterialBasedCupertinoThemeData(materialTheme: materialTheme);

    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return PlatformProvider(builder: (ctx) => PlatformSnackApp(
          title: 'Project Zomboid RCON',
          materialTheme: materialTheme,
          cupertinoTheme: cupertinoTheme,
          home: const MyHomePage(title: 'Server List'),
        ));
      },
    );
  }
}