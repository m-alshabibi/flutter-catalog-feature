import 'package:flutter_catalog_feature/core/result/result.dart';
import 'package:flutter_catalog_feature/core/error/failures.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/catalog_item_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/favorite_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/group_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/repositories/catalog_item_repository.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/repositories/favorite_repository.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/repositories/group_repository.dart';

class FakeGroupRepository implements GroupRepository {
  Result<List<GroupEntity>> groupsResult = const Success([]);
  Result<void> refreshResult = const Success(null);
  int getGroupsCalls = 0;
  int refreshCalls = 0;

  @override
  Future<Result<List<GroupEntity>>> getGroups() async {
    getGroupsCalls++;
    return groupsResult;
  }

  @override
  Future<Result<void>> refreshGroups() async {
    refreshCalls++;
    return refreshResult;
  }
}

class FakeCatalogItemRepository implements CatalogItemRepository {
  Result<Map<String, List<CatalogItemEntity>>> allItemsResult = const Success({});
  Result<List<CatalogItemEntity>> itemsResult = const Success([]);
  Result<List<CatalogItemEntity>> itemsByIdsResult = const Success([]);
  Result<CatalogItemEntity> itemResult = FailureResult(
    const FailureForTest(),
  );
  Result<void> refreshAllResult = const Success(null);
  Result<void> refreshGroupResult = const Success(null);

  int getAllCalls = 0;
  int getItemsCalls = 0;
  int getByIdsCalls = 0;
  int getByIdCalls = 0;
  int refreshAllCalls = 0;
  int refreshGroupCalls = 0;
  String? lastGroupId;
  Set<String>? lastIds;
  String? lastItemId;

  @override
  Future<Result<Map<String, List<CatalogItemEntity>>>> getAllCatalogItems() async {
    getAllCalls++;
    return allItemsResult;
  }

  @override
  Future<Result<List<CatalogItemEntity>>> getCatalogItems(String groupId) async {
    getItemsCalls++;
    lastGroupId = groupId;
    return itemsResult;
  }

  @override
  Future<Result<List<CatalogItemEntity>>> getCatalogItemsByIds(Set<String> ids) async {
    getByIdsCalls++;
    lastIds = ids;
    return itemsByIdsResult;
  }

  @override
  Future<Result<CatalogItemEntity>> getCatalogItemById(String id) async {
    getByIdCalls++;
    lastItemId = id;
    return itemResult;
  }

  @override
  Future<Result<void>> refreshCatalogItems() async {
    refreshAllCalls++;
    return refreshAllResult;
  }

  @override
  Future<Result<void>> refreshCatalogItemsByGroup(String groupId) async {
    refreshGroupCalls++;
    lastGroupId = groupId;
    return refreshGroupResult;
  }
}

class FakeFavoriteRepository implements FavoriteRepository {
  Result<List<FavoriteEntity>> favoritesResult = const Success([]);
  Result<void> addResult = const Success(null);
  Result<void> removeResult = const Success(null);
  Result<void> refreshResult = const Success(null);
  int getCalls = 0;
  int addCalls = 0;
  int removeCalls = 0;
  int refreshCalls = 0;
  String? lastUserId;
  String? lastCatalogItemId;

  @override
  Future<Result<List<FavoriteEntity>>> getFavorites(String userId) async {
    getCalls++;
    lastUserId = userId;
    return favoritesResult;
  }

  @override
  Future<Result<void>> addFavorite(String userId, String catalogItemId) async {
    addCalls++;
    lastUserId = userId;
    lastCatalogItemId = catalogItemId;
    return addResult;
  }

  @override
  Future<Result<void>> removeFavorite(String userId, String catalogItemId) async {
    removeCalls++;
    lastUserId = userId;
    lastCatalogItemId = catalogItemId;
    return removeResult;
  }

  @override
  Future<Result<void>> refreshFavorites(String userId) async {
    refreshCalls++;
    lastUserId = userId;
    return refreshResult;
  }
}

class FailureForTest extends Failure {
  const FailureForTest() : super('Test failure');
}
