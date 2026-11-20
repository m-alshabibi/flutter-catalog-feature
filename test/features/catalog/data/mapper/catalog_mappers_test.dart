import 'package:flutter_catalog_feature/features/catalog/data/datasources/local/database/app_database.dart';
import 'package:flutter_catalog_feature/features/catalog/data/mapper/catalog_item_mapper.dart';
import 'package:flutter_catalog_feature/features/catalog/data/mapper/group_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fixtures.dart';
import '../../../../support/test_database.dart';

void main() {
  late AppDatabase database;

  setUp(() async {
    database = createTestDatabase();
    await database.customStatement('PRAGMA foreign_keys = ON;');
  });

  tearDown(() async {
    await database.close();
  });

  test('GroupMapper maps a database row to a model and back', () async {
    final group = makeGroupModel(id: 'group-mapper', name: 'Mapper Group');

    await database
        .into(database.groupsTable)
        .insert(GroupMapper.modelToMap(group));

    final row = await (database.select(
      database.groupsTable,
    )..where((table) => table.id.equals(group.id))).getSingle();
    final mapped = GroupMapper.mapToModel(row);

    expect(mapped.id, group.id);
    expect(mapped.name, group.name);
    expect(mapped.description, group.description);
    expect(mapped.imageUrl, group.imageUrl);
    expect(mapped.sortOrder, group.sortOrder);
    expect(mapped.isActive, group.isActive);
    expect(mapped.createdAt.isAtSameMomentAs(mapped.createdAt), isTrue);
    expect(mapped.updatedAt, group.updatedAt);
  });

  test('CatalogItemMapper maps a database row to a model and back', () async {
    final group = makeGroupModel();
    final item = makeItemModel();

    await database
        .into(database.groupsTable)
        .insert(GroupMapper.modelToMap(group));
    await database
        .into(database.catalogItemsTable)
        .insert(CatalogItemMapper.modelToMap(item));

    final row = await (database.select(
      database.catalogItemsTable,
    )..where((table) => table.id.equals(item.id))).getSingle();
    final mapped = CatalogItemMapper.mapToModel(row);

    expect(mapped.id, item.id);
    expect(mapped.groupId, item.groupId);
    expect(mapped.name, item.name);
    expect(mapped.shortDescription, item.shortDescription);
    expect(mapped.longDescription, item.longDescription);
    expect(mapped.imageUrl, item.imageUrl);
    expect(mapped.gallery, item.gallery);
    expect(mapped.sortOrder, item.sortOrder);
    expect(mapped.isActive, item.isActive);
    expect(mapped.isFeatured, item.isFeatured);
    expect(mapped.metadata, item.metadata);
    expect(mapped.createdAt.isAtSameMomentAs(item.createdAt), isTrue);
    expect(mapped.updatedAt, item.updatedAt);
  });
}
