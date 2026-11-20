import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/result/result.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/get_catalog_items_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/get_groups_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/refresh_catalog_items_by_group_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/refresh_groups_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/catalog/catalog_cubit.dart';
import '../../../../support/fake_repositories.dart';
import '../../../../support/fixtures.dart';

void main() {
  late FakeGroupRepository groups;
  late FakeCatalogItemRepository items;
  late CatalogCubit cubit;

  setUp(() {
    groups = FakeGroupRepository()..groupsResult = Success([makeGroup()]);
    items = FakeCatalogItemRepository()..itemsResult = Success([makeItem()]);
    cubit = CatalogCubit(
      getGroupsUseCase: GetGroupsUseCase(groups),
      refreshGroupsUseCase: RefreshGroupsUseCase(groups),
      getCatalogItemsUseCase: GetCatalogItemsUseCase(items),
      refreshCatalogItemsByGroupUseCase: RefreshCatalogItemsByGroupUseCase(items),
    );
  });

  tearDown(() async => cubit.close());

  test('loads groups from local result and refreshes the catalog', () async {
    await cubit.loadCatalog();
    expect(cubit.state.groups.single.id, 'group-1');
    expect(cubit.state.hasLoaded, isTrue);
    expect(cubit.state.isLoading, isFalse);
    expect(groups.refreshCalls, 1);
  });

  test('loads group items independently and skips unknown groups', () async {
    await cubit.loadCatalog();
    await cubit.loadGroupItems('unknown');
    expect(items.getItemsCalls, 0);

    await cubit.loadGroupItems('group-1');
    expect(cubit.state.groupState('group-1').items.single.id, 'item-1');
    expect(cubit.state.groupState('group-1').hasLoaded, isTrue);
    expect(items.refreshGroupCalls, 1);
  });

  test('does not repeat a completed group load unless forced', () async {
    await cubit.loadCatalog();
    await cubit.loadGroupItems('group-1');
    final calls = items.getItemsCalls;
    await cubit.loadGroupItems('group-1');
    expect(items.getItemsCalls, calls);
    await cubit.loadGroupItems('group-1', forceRefresh: true);
    expect(items.getItemsCalls, calls + 2);
  });
}
