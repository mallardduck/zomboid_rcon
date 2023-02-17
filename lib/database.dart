import 'dart:ffi';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:zomboid_rcon/env/env.dart';

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

void setupSqlCipher() {
  open.overrideFor(
      OperatingSystem.android, () => DynamicLibrary.open('libsqlcipher.so'));
}

bool _debugCheckHasCipher(Database database) {
  return database.select('PRAGMA cipher_version;').isNotEmpty;
}

LazyDatabase _openConnection() {
  setupSqlCipher();
  return LazyDatabase(() async {
    final dbFolder = (await getApplicationSupportDirectory()).path;
    final file = File(p.join(dbFolder, 'secure.sqlite'));
    return NativeDatabase(
        file,
        setup: (rawDb) {
          assert(_debugCheckHasCipher(rawDb));

          // TODO: Sort out how a rekey should be done...consider device based key?
          // Then, apply the key to encrypt the database.
          rawDb.execute("PRAGMA key = '${Env.dbSecret}';");
          // Test that the key is correct by selecting from a table
          rawDb.execute('select count(*) from sqlite_master');
        }
    );
  });
}