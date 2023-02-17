import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zomboid_rcon/app.dart';
import 'package:window_size/window_size.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMinSize(const Size(450, 400));
    setWindowMaxSize(Size.infinite);
  }

  runApp(
      const ProviderScope(
          child: MyApp()
      )
  );
}
