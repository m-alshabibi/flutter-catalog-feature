import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/features/catalog/data/datasources/local/database/app_database.dart';
import 'package:flutter_catalog_feature/features/catalog/data/datasources/local/catalog_item_local_data_source.dart';
import 'package:flutter_catalog_feature/features/catalog/data/datasources/local/favorite_local_data_source.dart';
import 'package:flutter_catalog_feature/features/catalog/data/datasources/local/group_local_data_source.dart';
import '../../../../../support/fixtures.dart';
import '../../../../../support/test_database.dart';

void main() {
  late final AppDatabase db;
  late FavoriteLocalDataSourceImpl favorites;
  late GroupLocalDataSourceImpl groups;
  late CatalogItemLocalDataSourceImpl items;

  setUpAll(() async {
    db = createTestDatabase();
    await db.customStatement('PRAGMA foreign_keys = ON;');
  });
  setUp(() async {
    favorites = FavoriteLocalDataSourceImpl(db);
    groups = GroupLocalDataSourceImpl(db);
    items = CatalogItemLocalDataSourceImpl(db);
    await groups.syncGroups([makeGroupModel()]);
    await items.saveCatalogItems([makeItemModel()]);
  });
  tearDown(() async {
    await db.delete(db.favoritesTable).go();
    await db.delete(db.catalogItemsTable).go();
    await db.delete(db.groupsTable).go();
  });
  tearDownAll(() async {
    await db.close();
  });

  test('saves a local favorite as a pending addition', () async {
    await favorites.saveFavorite(makeFavoriteModel());
    expect((await favorites.getFavorites('user-1')).single.catalogItemId, 'item-1');
    final pending = await favorites.getPendingFavorites('user-1');
    expect(pending, hasLength(1));
    expect(pending.single.isDeleted, isFalse);
  });

  test('marks an added favorite synchronized', () async {
    await favorites.saveFavorite(makeFavoriteModel());
    await favorites.markFavoriteAsSynced(
      userId: 'user-1', catalogItemId: 'item-1', wasDeleted: false,
    );
    expect(await favorites.getPendingFavorites('user-1'), isEmpty);
  });

  test('removal creates a pending tombstone and excludes it from visible favorites', () async {
    await favorites.saveFavorite(makeFavoriteModel());
    await favorites.markFavoriteAsSynced(
      userId: 'user-1', catalogItemId: 'item-1', wasDeleted: false,
    );
    await favorites.removeFavorite('user-1', 'item-1');
    expect(await favorites.getFavorites('user-1'), isEmpty);
    final pending = await favorites.getPendingFavorites('user-1');
    expect(pending.single.isDeleted, isTrue);
  });

  test('remote snapshot removes old synchronized records but preserves pending changes', () async {
    await favorites.syncFavorites(
      userId: 'user-1',
      favorites: [makeFavoriteModel()],
    );
    await favorites.removeFavorite('user-1', 'item-1');
    await favorites.syncFavorites(userId: 'user-1', favorites: const []);
    expect(await favorites.getFavorites('user-1'), isEmpty);
    expect(await favorites.getPendingFavorites('user-1'), hasLength(1));
    expect((await favorites.getPendingFavorites('user-1')).single.isDeleted, isTrue);
  });

  test('remote snapshots are scoped to the requested user', () async {
    await favorites.syncFavorites(
      userId: 'user-1',
      favorites: [makeFavoriteModel(), makeFavoriteModel(userId: 'user-2', id: 'other-favorite')],
    );
    expect(await favorites.getFavorites('user-1'), hasLength(1));
    expect(await favorites.getFavorites('user-2'), isEmpty);
  });
}
