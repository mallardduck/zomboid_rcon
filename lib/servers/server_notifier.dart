import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/server.dart';

class ServerNotifier extends StateNotifier<List<Server>> {
  ServerNotifier({List<Server>? initialServers}) : super(initialServers ?? []);

  void addServer(Server server) {
    state = [
      ...state,
      server
    ];
  }

  void updateServer(Server updated) {
    state = [
      for (final server in state)
        (server.id != updated.id) ? server : updated,
    ];
  }

  void removeServer(String serverId) {
    state = [
      for (final server in state)
        if (server.id != serverId) server,
    ];
  }
}