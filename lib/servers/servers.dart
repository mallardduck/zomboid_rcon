import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/server.dart';
export 'models/server.dart';
import 'server_notifier.dart';
export 'server_notifier.dart';

final serversProvider = StateNotifierProvider<ServerNotifier, List<Server>>((ref) {
  // TODO: init tasks from DB
  return ServerNotifier(initialServers: [
    Server(
      name: 'Ducks Pond',
      address: '192.168.32.124',
      port: 27015,
      password: 'adminfam'
    ),
  ]);
});