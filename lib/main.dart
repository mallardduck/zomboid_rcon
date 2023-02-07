import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zomboid_rcon/app.dart';
import 'package:zomboid_rcon/database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
      const ProviderScope(
          child: MyApp()
      )
  );
}
