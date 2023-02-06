import 'dart:io';

extension PlatformExtension on Platform {
  String get lineSeparator => Platform.isWindows | Platform.isIOS | Platform.isMacOS
      ? '\r\n'
      : Platform.isLinux
      ? '\n'
      : '\n';
}

/// The type definition for a JSON-serializable [Map].
typedef JsonMap = Map<String, dynamic>;
