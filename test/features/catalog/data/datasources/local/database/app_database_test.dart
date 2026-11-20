import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/features/catalog/data/datasources/local/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('AppDatabase', () {
    test('should enable foreign key enforcement', () async {
      final result = await database
          .customSelect('PRAGMA foreign_keys')
          .getSingle();

      expect(result.read<int>('foreign_keys'), 1);
    });

    test(
      'should cascade delete favorites when their group is deleted',
      () async {
        final now = DateTime.now();

        // Insert a group.
        await database
            .into(database.groupsTable)
            .insert(
              GroupsTableCompanion.insert(
                id: 'group-1',
                name: 'Group 1',
                createdAt: now,
                updatedAt: now,
              ),
            );

        // Insert a catalog item.
        await database
            .into(database.catalogItemsTable)
            .insert(
              CatalogItemsTableCompanion.insert(
                id: 'item-1',
                groupId: 'group-1',
                name: 'Item 1',
                gallery: const [],
                createdAt: now,
                updatedAt: now,
              ),
            );

        // Insert a favorite.
        await database
            .into(database.favoritesTable)
            .insert(
              FavoritesTableCompanion.insert(
                id: 'favorite-1',
                userId: 'user-1',
                catalogItemId: 'item-1',
                createdAt: now,
                updatedAt: now,
              ),
            );

        // Delete the group.
        await (database.delete(
          database.groupsTable,
        )..where((table) => table.id.equals('group-1'))).go();

        final items = await database.select(database.catalogItemsTable).get();
        final favorites = await database.select(database.favoritesTable).get();

        expect(items, isEmpty);
        expect(favorites, isEmpty);
      },
    );

    test(
      'should prevent duplicate favorites for the same user and item',
      () async {
        final now = DateTime.now();

        await database
            .into(database.groupsTable)
            .insert(
              GroupsTableCompanion.insert(
                id: 'group-1',
                name: 'Group 1',
                createdAt: now,
                updatedAt: now,
              ),
            );

        await database
            .into(database.catalogItemsTable)
            .insert(
              CatalogItemsTableCompanion.insert(
                id: 'item-1',
                groupId: 'group-1',
                name: 'Item 1',
                gallery: const [],
                createdAt: now,
                updatedAt: now,
              ),
            );

        final favorite = FavoritesTableCompanion.insert(
          id: 'favorite-1',
          userId: 'user-1',
          catalogItemId: 'item-1',
          createdAt: now,
          updatedAt: now,
        );

        await database.into(database.favoritesTable).insert(favorite);

        await expectLater(
          database
              .into(database.favoritesTable)
              .insert(
                FavoritesTableCompanion.insert(
                  id: 'favorite-2',
                  userId: 'user-1',
                  catalogItemId: 'item-1',
                  createdAt: now,
                  updatedAt: now,
                ),
              ),
          throwsA(anything),
        );
      },
    );
  });
}
