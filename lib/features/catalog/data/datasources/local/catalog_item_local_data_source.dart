import 'package:drift/drift.dart';

import '../../mapper/catalog_item_mapper.dart';
import '../../models/catalog_item_model.dart';
import 'database/app_database.dart';

abstract interface class CatalogItemLocalDataSource {
  Future<Map<String, List<CatalogItemModel>>> getAllCatalogItems();

  Future<List<CatalogItemModel>> getCatalogItems(String groupId);

  Future<List<CatalogItemModel>> getCatalogItemsByIds(Set<String> ids);

  Future<CatalogItemModel?> getCatalogItemById(String id);

  /// Saves individual items without treating the input as a complete snapshot.
  Future<void> saveCatalogItems(List<CatalogItemModel> items);

  /// Applies a complete catalog snapshot, optionally scoped to one group.
  ///
  /// When [groupId] is null, the list represents the complete catalog.
  /// Otherwise, it represents the complete item list for that group only.
  Future<void> syncCatalogItems(
    List<CatalogItemModel> items, {
    String? groupId,
  });
}

class CatalogItemLocalDataSourceImpl implements CatalogItemLocalDataSource {
  final AppDatabase _database;

  CatalogItemLocalDataSourceImpl(this._database);

  @override
  Future<Map<String, List<CatalogItemModel>>> getAllCatalogItems() async {
    final query = _database.select(_database.catalogItemsTable)
      ..where((table) => table.isActive.equals(true))
      ..orderBy([
        (table) => OrderingTerm.asc(table.sortOrder),
        (table) => OrderingTerm.asc(table.name),
      ]);

    final rows = await query.get();

    final result = <String, List<CatalogItemModel>>{};

    for (final row in rows) {
      result.putIfAbsent(row.groupId, () => []);
      result[row.groupId]!.add(CatalogItemMapper.mapToModel(row));
    }

    return result;
  }

  @override
  Future<List<CatalogItemModel>> getCatalogItems(String groupId) async {
    final query = _database.select(_database.catalogItemsTable)
      ..where(
        (table) =>
            table.groupId.equals(groupId) & table.isActive.equals(true),
      )
      ..orderBy([
        (table) => OrderingTerm.asc(table.sortOrder),
        (table) => OrderingTerm.asc(table.name),
      ]);

    final rows = await query.get();

    return rows.map(CatalogItemMapper.mapToModel).toList();
  }

  @override
  Future<List<CatalogItemModel>> getCatalogItemsByIds(Set<String> ids) async {
    if (ids.isEmpty) return [];

    final query = _database.select(_database.catalogItemsTable)
      ..where((table) => table.id.isIn(ids))
      ..orderBy([
        (table) => OrderingTerm.asc(table.sortOrder),
        (table) => OrderingTerm.asc(table.name),
      ]);

    final rows = await query.get();

    return rows.map(CatalogItemMapper.mapToModel).toList();
  }

  @override
  Future<CatalogItemModel?> getCatalogItemById(String id) async {
    final query = _database.select(_database.catalogItemsTable)
      ..where((table) => table.id.equals(id));

    final row = await query.getSingleOrNull();

    if (row == null) return null;

    return CatalogItemMapper.mapToModel(row);
  }

  @override
  Future<void> saveCatalogItems(List<CatalogItemModel> items) async {
    await _database.transaction(() async {
      for (final item in items) {
        await _database
            .into(_database.catalogItemsTable)
            .insertOnConflictUpdate(CatalogItemMapper.modelToMap(item));
      }
    });
  }

  @override
  Future<void> syncCatalogItems(
    List<CatalogItemModel> items, {
    String? groupId,
  }) async {
    await _database.transaction(() async {
      for (final item in items) {
        await _database
            .into(_database.catalogItemsTable)
            .insertOnConflictUpdate(CatalogItemMapper.modelToMap(item));
      }

      final receivedIds = items.map((item) => item.id).toSet();
      final update = _database.update(_database.catalogItemsTable);

      if (groupId == null) {
        if (receivedIds.isEmpty) {
          await update.write(
            const CatalogItemsTableCompanion(isActive: Value(false)),
          );
        } else {
          await (update
                ..where((table) => table.id.isNotIn(receivedIds)))
              .write(
            const CatalogItemsTableCompanion(isActive: Value(false)),
          );
        }
      } else if (receivedIds.isEmpty) {
        await (update..where((table) => table.groupId.equals(groupId))).write(
          const CatalogItemsTableCompanion(isActive: Value(false)),
        );
      } else {
        await (update
              ..where(
                (table) =>
                    table.groupId.equals(groupId) &
                    table.id.isNotIn(receivedIds),
              ))
            .write(
          const CatalogItemsTableCompanion(isActive: Value(false)),
        );
      }
    });
  }
}
