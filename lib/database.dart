import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:zomboid_rcon/servers/servers.dart';

part 'database.g.dart';

class DatabaseProvider {
  static final DatabaseProvider instance = DatabaseProvider._init();
  static MyDatabase? _db;

  DatabaseProvider._init();

  Future<MyDatabase> get db async {
    if (_db != null) return _db!;
    _db = MyDatabase();
    return _db!;
  }
}

@DriftDatabase(tables: [Servers,])
class MyDatabase extends _$MyDatabase {
  // we tell the database where to store the data with this constructor
  MyDatabase() : super(_openConnection());

  // you should bump this number whenever you change or add a table definition.
  // Migrations are covered later in the documentation.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
    );
  }

  Future<List<Server>> get allServers => select(servers).get();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = (await getApplicationSupportDirectory()).path;
    final file = File(p.join(dbFolder, 'db.sqlite'));
    return NativeDatabase(file);
  });
}