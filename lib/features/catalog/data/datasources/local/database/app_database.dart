import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/catalog_items_table.dart';
import 'tables/favorites_table.dart';
import 'tables/groups_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [GroupsTable, CatalogItemsTable, FavoritesTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(
        executor ??
            driftDatabase(
              name: 'catalog_database',
              web: DriftWebOptions(
                sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                driftWorker: Uri.parse('drift_worker.js'),
              ),
            ),
      );

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON;');
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(favoritesTable, favoritesTable.isSynced);

        await m.addColumn(favoritesTable, favoritesTable.isDeleted);
      }
    },
  );
}
