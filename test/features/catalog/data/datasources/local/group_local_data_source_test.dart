import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/features/catalog/data/datasources/local/database/app_database.dart';
import 'package:flutter_catalog_feature/features/catalog/data/datasources/local/group_local_data_source.dart';
import 'package:flutter_catalog_feature/features/catalog/data/models/group_model.dart';
import '../../../../../support/fixtures.dart';
import '../../../../../support/test_database.dart';

void main() {
  late final AppDatabase db;
  late GroupLocalDataSourceImpl source;

  setUpAll(() async {
    db = createTestDatabase();
    await db.customStatement('PRAGMA foreign_keys = ON;');
  });
  setUp(() => source = GroupLocalDataSourceImpl(db));
  tearDown(() async {
    await db.delete(db.groupsTable).go();
  });
  tearDownAll(() async {
    await db.close();
  });

  test('syncGroups stores groups and sorts active results', () async {
    await source.syncGroups([
      makeGroupModel(id: 'g2', name: 'Beta'),
      makeGroupModel(id: 'g1', name: 'Alpha'),
    ]);
    final result = await source.getGroups();
    expect(result.map((group) => group.id), ['g1', 'g2']);
    expect(result.first.description, 'Description');
    expect(result.first.sortOrder, 1);
    expect(await source.getStoredGroupIds({'g1', 'missing'}), {'g1'});
  });

  test('a complete snapshot marks groups absent from the response inactive', () async {
    await source.syncGroups([makeGroupModel(), makeGroupModel(id: 'g2', name: 'Other')]);
    await source.syncGroups([makeGroupModel()]);
    expect((await source.getGroups()).map((group) => group.id), ['group-1']);
    expect(await source.getStoredGroupIds({'g2'}), {'g2'});
  });

  test('an empty snapshot marks every stored group inactive', () async {
    await source.syncGroups([makeGroupModel()]);
    await source.syncGroups(const <GroupModel>[]);
    expect(await source.getGroups(), isEmpty);
  });
}
