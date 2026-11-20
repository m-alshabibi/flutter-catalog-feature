import 'package:drift/drift.dart';

import 'catalog_items_table.dart';

@TableIndex(name: 'idx_favorites_catalog_item', columns: {#catalogItemId})
class FavoritesTable extends Table {
  TextColumn get id => text()();

  TextColumn get userId => text()();

  TextColumn get catalogItemId =>
      text().references(CatalogItemsTable, #id, onDelete: KeyAction.cascade)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();

  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {userId, catalogItemId},
  ];

  @override
  String get tableName => 'favorites';
}
