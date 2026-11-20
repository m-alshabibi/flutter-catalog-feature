import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/domain/usecases/no_params.dart';
import 'package:flutter_catalog_feature/core/result/result.dart';
import 'package:flutter_catalog_feature/core/error/failures.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/catalog_item_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/favorite_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/models/catalog_item_with_favorite.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/add_favorite_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/get_all_catalog_items_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/get_catalog_item_by_id_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/get_catalog_items_by_ids_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/get_catalog_items_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/get_catalog_items_with_favorite_status_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/get_favorite_catalog_items_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/get_favorites_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/get_groups_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/get_groups_with_catalog_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/params/add_favorite_params.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/refresh_catalog_items_by_group_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/refresh_catalog_items_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/refresh_favorites_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/refresh_groups_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/remove_favorite_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/group_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/models/group_with_catalog.dart';
import '../../../../support/fake_repositories.dart';
import '../../../../support/fixtures.dart';

void main() {
  late FakeGroupRepository groups;
  late FakeCatalogItemRepository items;
  late FakeFavoriteRepository favorites;

  setUp(() {
    groups = FakeGroupRepository();
    items = FakeCatalogItemRepository();
    favorites = FakeFavoriteRepository();
  });

  test('simple group and catalog use cases delegate to repositories', () async {
    groups.groupsResult = Success([makeGroup()]);
    items.itemsResult = Success([makeItem()]);
    items.itemResult = Success(makeItem());
    items.allItemsResult = Success({'group-1': [makeItem()]});

    expect((await GetGroupsUseCase(groups)(const NoParams())), isA<Success<List<GroupEntity>>>());
    expect(groups.getGroupsCalls, 1);

    expect((await GetCatalogItemsUseCase(items)('group-1')), isA<Success<List<CatalogItemEntity>>>());
    expect(items.lastGroupId, 'group-1');

    expect((await GetCatalogItemByIdUseCase(items)('item-1')), isA<Success<CatalogItemEntity>>());
    expect(items.lastItemId, 'item-1');

    expect((await GetCatalogItemsByIdsUseCase(items)({'item-1'})), isA<Success<List<CatalogItemEntity>>>());
    expect(items.lastIds, {'item-1'});

    expect((await GetAllCatalogItemsUseCase(items)(const NoParams())), isA<Success<Map<String, List<CatalogItemEntity>>>>());
  });

  test('favorite use cases delegate with the given user and item IDs', () async {
    const params = AddFavoriteParams(userId: 'user-1', catalogItemId: 'item-1');
    await AddFavoriteUseCase(favorites)(params);
    expect(favorites.addCalls, 1);
    expect(favorites.lastUserId, 'user-1');
    expect(favorites.lastCatalogItemId, 'item-1');

    await RemoveFavoriteUseCase(favorites)(params);
    expect(favorites.removeCalls, 1);

    await GetFavoritesUseCase(favorites)('user-1');
    expect(favorites.getCalls, 1);

    await RefreshFavoritesUseCase(favorites)('user-1');
    expect(favorites.refreshCalls, 1);
  });

  test('refresh use cases delegate to their repositories', () async {
    await RefreshGroupsUseCase(groups)(const NoParams());
    await RefreshCatalogItemsUseCase(items)(const NoParams());
    await RefreshCatalogItemsByGroupUseCase(items)('group-1');
    expect(groups.refreshCalls, 1);
    expect(items.refreshAllCalls, 1);
    expect(items.refreshGroupCalls, 1);
  });

  test('GetFavoriteCatalogItemsUseCase returns empty without querying catalog', () async {
    favorites.favoritesResult = const Success<List<FavoriteEntity>>([]);
    final result = await GetFavoriteCatalogItemsUseCase(
      favoriteRepository: favorites,
      catalogItemRepository: items,
    )('user-1');
    expect((result as Success<List<CatalogItemEntity>>).data, isEmpty);
    expect(items.getByIdsCalls, 0);
  });

  test('GetFavoriteCatalogItemsUseCase resolves favorite IDs to items', () async {
    favorites.favoritesResult = Success([makeFavorite(catalogItemId: 'item-1')]);
    items.itemsByIdsResult = Success([makeItem()]);
    final result = await GetFavoriteCatalogItemsUseCase(
      favoriteRepository: favorites,
      catalogItemRepository: items,
    )('user-1');
    expect((result as Success<List<CatalogItemEntity>>).data.single.id, 'item-1');
    expect(items.lastIds, {'item-1'});
  });

  test('GetFavoriteCatalogItemsUseCase propagates favorite and catalog failures', () async {
    const failure = NetworkFailure('offline');
    favorites.favoritesResult = const FailureResult(failure);
    final useCase = GetFavoriteCatalogItemsUseCase(
      favoriteRepository: favorites,
      catalogItemRepository: items,
    );
    expect((await useCase('user-1') as FailureResult).failure, same(failure));

    favorites.favoritesResult = Success([makeFavorite()]);
    items.itemsByIdsResult = const FailureResult(failure);
    expect((await useCase('user-1') as FailureResult).failure, same(failure));
  });

  test('GetGroupsWithCatalogUseCase joins groups with grouped catalog items', () async {
    groups.groupsResult = Success([makeGroup(), makeGroup(id: 'empty', name: 'Empty')]);
    items.allItemsResult = Success({'group-1': [makeItem()]});
    final result = await GetGroupsWithCatalogUseCase(
      groupRepository: groups,
      catalogItemRepository: items,
    )(const NoParams());

    final data = (result as Success<List<GroupWithCatalog>>).data;
    expect(data, hasLength(2));
    expect(data.first.catalogItems.single.id, 'item-1');
    expect(data.last.catalogItems, isEmpty);
  });

  test('GetCatalogItemsWithFavoriteStatusUseCase attaches favorite flags', () async {
    items.allItemsResult = Success({'group-1': [makeItem(), makeItem(id: 'item-2')]});
    favorites.favoritesResult = Success([makeFavorite(catalogItemId: 'item-2')]);
    final result = await GetCatalogItemsWithFavoriteStatusUseCase(
      catalogItemRepository: items,
      favoriteRepository: favorites,
    )('user-1');

    final data = (result as Success<Map<String, List<CatalogItemWithFavorite>>>).data;
    expect(data['group-1']![0].isFavorite, isFalse);
    expect(data['group-1']![1].isFavorite, isTrue);
  });

  test('composite use cases propagate repository failures', () async {
    const failure = NetworkFailure('offline');
    groups.groupsResult = const FailureResult(failure);
    final groupsWithCatalog = await GetGroupsWithCatalogUseCase(
      groupRepository: groups,
      catalogItemRepository: items,
    )(const NoParams());
    expect((groupsWithCatalog as FailureResult).failure, same(failure));

    items.allItemsResult = const FailureResult(failure);
    groups.groupsResult = Success([makeGroup()]);
    final itemsWithFavorite = await GetCatalogItemsWithFavoriteStatusUseCase(
      catalogItemRepository: items,
      favoriteRepository: favorites,
    )('user-1');
    expect((itemsWithFavorite as FailureResult).failure, same(failure));
  });
}
