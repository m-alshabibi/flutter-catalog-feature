import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/features/catalog/data/datasources/local/database/app_database.dart';
import 'package:flutter_catalog_feature/features/catalog/data/datasources/local/catalog_item_local_data_source.dart';
import 'package:flutter_catalog_feature/features/catalog/data/datasources/local/group_local_data_source.dart';
import '../../../../../support/fixtures.dart';
import '../../../../../support/test_database.dart';

void main() {
  late final AppDatabase db;
  late CatalogItemLocalDataSourceImpl items;
  late GroupLocalDataSourceImpl groups;

  setUpAll(() async {
    db = createTestDatabase();
    await db.customStatement('PRAGMA foreign_keys = ON;');
  });
  setUp(() async {
    items = CatalogItemLocalDataSourceImpl(db);
    groups = GroupLocalDataSourceImpl(db);
    await groups.syncGroups([makeGroupModel(), makeGroupModel(id: 'group-2', name: 'Two')]);
  });
  tearDown(() async {
    await db.delete(db.catalogItemsTable).go();
    await db.delete(db.groupsTable).go();
  });
  tearDownAll(() async {
    await db.close();
  });

  test('saves and retrieves items by group and IDs', () async {
    await items.saveCatalogItems([makeItemModel(), makeItemModel(id: 'item-2', name: 'Second')]);
    expect((await items.getCatalogItems('group-1')).map((item) => item.id), ['item-1', 'item-2']);
    expect((await items.getCatalogItemsByIds({'item-2'})).single.id, 'item-2');
    final stored = await items.getCatalogItemById('item-1');
    expect(stored!.gallery, ['https://example.com/1.png']);
    expect(stored.metadata, {'color': 'blue'});
    expect((await items.getCatalogItemById('missing')), isNull);
    expect((await items.getAllCatalogItems()).keys, contains('group-1'));
  });

  test('a group snapshot deactivates missing items only in that group', () async {
    await items.saveCatalogItems([
      makeItemModel(id: 'item-1'),
      makeItemModel(id: 'item-2', name: 'Second'),
      makeItemModel(id: 'item-3', groupId: 'group-2'),
    ]);
    await items.syncCatalogItems([makeItemModel()], groupId: 'group-1');

    expect((await items.getCatalogItems('group-1')).map((item) => item.id), ['item-1']);
    expect((await items.getCatalogItems('group-2')).map((item) => item.id), ['item-3']);
  });

  test('an empty group snapshot deactivates all items in that group', () async {
    await items.saveCatalogItems([makeItemModel(), makeItemModel(id: 'item-2', name: 'Second')]);
    await items.syncCatalogItems(const [], groupId: 'group-1');
    expect(await items.getCatalogItems('group-1'), isEmpty);
  });

  test('a full snapshot deactivates items missing from all groups', () async {
    await items.saveCatalogItems([
      makeItemModel(),
      makeItemModel(id: 'item-2', groupId: 'group-2'),
    ]);
    await items.syncCatalogItems([makeItemModel()]);
    expect((await items.getCatalogItems('group-2')), isEmpty);
  });
}
