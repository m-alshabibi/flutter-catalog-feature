import 'package:flutter_catalog_feature/core/error/exceptions.dart';
import 'package:flutter_catalog_feature/features/catalog/data/datasources/local/catalog_item_local_data_source.dart';
import 'package:flutter_catalog_feature/features/catalog/data/datasources/local/favorite_local_data_source.dart';
import 'package:flutter_catalog_feature/features/catalog/data/datasources/local/group_local_data_source.dart';
import 'package:flutter_catalog_feature/features/catalog/data/datasources/remote/catalog_item_remote_data_source.dart';
import 'package:flutter_catalog_feature/features/catalog/data/datasources/remote/favorite_remote_data_source.dart';
import 'package:flutter_catalog_feature/features/catalog/data/datasources/remote/group_remote_data_source.dart';
import 'package:flutter_catalog_feature/features/catalog/data/models/catalog_item_model.dart';
import 'package:flutter_catalog_feature/features/catalog/data/models/favorite_model.dart';
import 'package:flutter_catalog_feature/features/catalog/data/models/group_model.dart';

class FakeGroupLocalDataSource implements GroupLocalDataSource {
  List<GroupModel> groups = [];
  Set<String> storedIds = {};
  List<GroupModel>? lastSynced;
  AppException? error;

  @override
  Future<List<GroupModel>> getGroups() async {
    if (error != null) throw error!;
    return groups;
  }

  @override
  Future<Set<String>> getStoredGroupIds(Set<String> ids) async => storedIds.intersection(ids);

  @override
  Future<void> syncGroups(List<GroupModel> groups) async {
    if (error != null) throw error!;
    lastSynced = groups;
    this.groups = groups;
    storedIds = groups.map((group) => group.id).toSet();
  }
}

class FakeGroupRemoteDataSource implements GroupRemoteDataSource {
  List<GroupModel> groups = [];
  AppException? error;
  @override
  Future<List<GroupModel>> getGroups() async {
    if (error != null) throw error!;
    return groups;
  }
}

class FakeCatalogItemLocalDataSource implements CatalogItemLocalDataSource {
  final Map<String, List<CatalogItemModel>> grouped = {};
  List<CatalogItemModel>? lastSaved;
  List<CatalogItemModel>? lastSynced;
  String? lastSyncGroupId;
  AppException? error;

  List<CatalogItemModel> get _all => grouped.values.expand((items) => items).toList();

  @override
  Future<Map<String, List<CatalogItemModel>>> getAllCatalogItems() async {
    if (error != null) throw error!;
    return grouped;
  }

  @override
  Future<List<CatalogItemModel>> getCatalogItems(String groupId) async {
    if (error != null) throw error!;
    return grouped[groupId] ?? [];
  }

  @override
  Future<List<CatalogItemModel>> getCatalogItemsByIds(Set<String> ids) async {
    if (error != null) throw error!;
    return _all.where((item) => ids.contains(item.id)).toList();
  }

  @override
  Future<CatalogItemModel?> getCatalogItemById(String id) async {
    if (error != null) throw error!;
    for (final item in _all) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<void> saveCatalogItems(List<CatalogItemModel> items) async {
    if (error != null) throw error!;
    lastSaved = items;
    for (final item in items) {
      final list = grouped.putIfAbsent(item.groupId, () => []);
      list.removeWhere((old) => old.id == item.id);
      list.add(item);
    }
  }

  @override
  Future<void> syncCatalogItems(List<CatalogItemModel> items, {String? groupId}) async {
    if (error != null) throw error!;
    lastSynced = items;
    lastSyncGroupId = groupId;
    if (groupId == null) grouped.clear(); else grouped.remove(groupId);
    for (final item in items) {
      grouped.putIfAbsent(item.groupId, () => []).add(item);
    }
  }
}

class FakeCatalogItemRemoteDataSource implements CatalogItemRemoteDataSource {
  Map<String, List<CatalogItemModel>> grouped = {};
  Map<String, CatalogItemModel> byId = {};
  AppException? error;

  @override
  Future<Map<String, List<CatalogItemModel>>> getAllCatalogItems() async {
    if (error != null) throw error!;
    return grouped;
  }

  @override
  Future<List<CatalogItemModel>> getCatalogItems(String groupId) async {
    if (error != null) throw error!;
    return grouped[groupId] ?? [];
  }

  @override
  Future<CatalogItemModel> getCatalogItemById(String id) async {
    if (error != null) throw error!;
    final direct = byId[id];
    if (direct != null) return direct;
    for (final item in grouped.values.expand((items) => items)) {
      if (item.id == id) return item;
    }
    throw const NotFoundException();
  }
}

class FakeFavoriteLocalDataSource implements FavoriteLocalDataSource {
  List<FavoriteModel> favorites = [];
  List<PendingFavoriteOperation> pending = [];
  FavoriteModel? saved;
  String? lastRemovedUserId;
  String? lastRemovedItemId;
  String? syncUserId;
  List<FavoriteModel>? synced;
  AppException? error;

  @override
  Future<List<FavoriteModel>> getFavorites(String userId) async {
    if (error != null) throw error!;
    return favorites.where((favorite) => favorite.userId == userId).toList();
  }

  @override
  Future<void> saveFavorite(FavoriteModel favorite) async {
    if (error != null) throw error!;
    saved = favorite;
    favorites = [...favorites.where((f) => f.catalogItemId != favorite.catalogItemId), favorite];
  }

  @override
  Future<void> syncFavorites({required String userId, required List<FavoriteModel> favorites}) async {
    if (error != null) throw error!;
    syncUserId = userId;
    synced = favorites;
    this.favorites = favorites.where((f) => f.userId == userId).toList();
  }

  @override
  Future<void> removeFavorite(String userId, String catalogItemId) async {
    if (error != null) throw error!;
    lastRemovedUserId = userId;
    lastRemovedItemId = catalogItemId;
    favorites.removeWhere((f) => f.userId == userId && f.catalogItemId == catalogItemId);
  }

  @override
  Future<List<PendingFavoriteOperation>> getPendingFavorites(String userId) async {
    if (error != null) throw error!;
    return pending.where((op) => op.favorite.userId == userId).toList();
  }

  @override
  Future<void> markFavoriteAsSynced({required String userId, required String catalogItemId, required bool wasDeleted}) async {
    if (error != null) throw error!;
    pending.removeWhere((op) => op.favorite.userId == userId && op.favorite.catalogItemId == catalogItemId);
  }
}

class FakeFavoriteRemoteDataSource implements FavoriteRemoteDataSource {
  List<FavoriteModel> favorites = [];
  final List<String> added = [];
  final List<String> removed = [];
  AppException? error;

  @override
  Future<List<FavoriteModel>> getFavorites(String userId) async {
    if (error != null) throw error!;
    return favorites.where((favorite) => favorite.userId == userId).toList();
  }

  @override
  Future<void> addFavorite(String userId, String catalogItemId) async {
    if (error != null) throw error!;
    added.add('$userId:$catalogItemId');
  }

  @override
  Future<void> removeFavorite(String userId, String catalogItemId) async {
    if (error != null) throw error!;
    removed.add('$userId:$catalogItemId');
  }
}
