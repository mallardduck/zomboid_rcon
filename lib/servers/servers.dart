import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zomboid_rcon/database.dart';

import 'models/server.dart';
export 'models/server.dart';

final databaseProvider = Provider((ref) => DatabaseProvider.instance);

final serversProvider = StateNotifierProvider<ServerNotifier, List<Server>>((ref) => ServerNotifier(ref));

class ServerNotifier extends StateNotifier<List<Server>> {
  final Ref ref;
  final DatabaseProvider _databaseProvider;
  ServerNotifier(this.ref)
      : _databaseProvider = ref.watch(databaseProvider),
        super([]) {
    _fetchServers();
  }

  Future<void> _fetchServers() async {
    final db = await _databaseProvider.db;
    state = await db.allServers;
  }

  Future<void> addServer({
    required String name,
    required String address,
    required int port,
    required String password,
  }) async {
    final database = await _databaseProvider.db;
    await database
        .into(database.servers)
        .insert(ServersCompanion.insert(
          name: name,
          address: address,
          port: port,
          password: password,
        ));
    _fetchServers();
  }

  Future<void> updateServer({
    required Server updated,
  }) async {
    final database = await _databaseProvider.db;
    await database
        .into(database.servers)
        .insertOnConflictUpdate(updated);
    _fetchServers();
  }

  Future<void> removeServer(int serverId) async {
    final database = await _databaseProvider.db;
    database.servers.deleteWhere((tbl) => tbl.id.equals(serverId));
    _fetchServers();
  }
}
