import 'package:drift/drift.dart';

class GroupsTable extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get description => text().nullable()();

  TextColumn get imageUrl => text().nullable()();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'groups';
}
