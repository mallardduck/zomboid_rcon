import 'package:drift/drift.dart';

class Servers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 32)();
  TextColumn get address => text().withLength(min: 1)();
  IntColumn get port => integer()();
  TextColumn get password => text().withLength(min: 1)();
}