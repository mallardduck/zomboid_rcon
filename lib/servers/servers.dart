import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/server.dart';
export 'models/server.dart';
import 'server_notifier.dart';
export 'server_notifier.dart';

final serversProvider = StateNotifierProvider<ServerNotifier, List<Server>>((ref) {
  // TODO: init tasks from DB
  return ServerNotifier();
});