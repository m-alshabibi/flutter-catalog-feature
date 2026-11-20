import 'package:drift/drift.dart';

import 'groups_table.dart';

@TableIndex(
  name: 'idx_catalog_items_active_sort',
  columns: {#isActive, #sortOrder},
)
class CatalogItemsTable extends Table {
  TextColumn get id => text()();

  TextColumn get groupId =>
      text().references(GroupsTable, #id, onDelete: KeyAction.cascade)();

  TextColumn get name => text()();

  TextColumn get shortDescription => text().nullable()();

  TextColumn get longDescription => text().nullable()();

  TextColumn get imageUrl => text().nullable()();

  TextColumn get gallery => text().map(const StringListConverter())();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  BoolColumn get isFeatured => boolean().withDefault(const Constant(false))();

  TextColumn get metadata => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'catalog_items';
}

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    return (fromDb.split('\n'));
  }

  @override
  String toSql(List<String> value) {
    return value.join('\n');
  }
}
