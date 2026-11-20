import 'package:flutter_catalog_feature/features/catalog/data/models/catalog_item_model.dart';
import 'package:flutter_catalog_feature/features/catalog/data/models/favorite_model.dart';
import 'package:flutter_catalog_feature/features/catalog/data/models/group_model.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/catalog_item_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/favorite_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/group_entity.dart';

final testCreatedAt = DateTime.utc(2025, 1, 1);
final testUpdatedAt = DateTime.utc(2025, 1, 2);

GroupEntity makeGroup({
  String id = 'group-1',
  String name = 'Group One',
  bool isActive = true,
}) => GroupEntity(
  id: id,
  name: name,
  description: 'Description',
  sortOrder: 1,
  isActive: isActive,
  createdAt: testCreatedAt,
  updatedAt: testUpdatedAt,
);

GroupModel makeGroupModel({
  String id = 'group-1',
  String name = 'Group One',
  bool isActive = true,
}) => GroupModel(
  id: id,
  name: name,
  description: 'Description',
  imageUrl: 'https://example.com/group.png',
  sortOrder: 1,
  isActive: isActive,
  createdAt: testCreatedAt,
  updatedAt: testUpdatedAt,
);

CatalogItemEntity makeItem({
  String id = 'item-1',
  String groupId = 'group-1',
  String name = 'Item One',
  List<String> gallery = const ['https://example.com/1.png'],
  String? imageUrl = 'https://example.com/item.png',
  bool isActive = true,
}) => CatalogItemEntity(
  id: id,
  groupId: groupId,
  name: name,
  shortDescription: 'Short description',
  longDescription: 'Long description',
  imageUrl: imageUrl,
  gallery: gallery,
  sortOrder: 2,
  isActive: isActive,
  isFeatured: true,
  metadata: const {'color': 'blue'},
  createdAt: testCreatedAt,
  updatedAt: testUpdatedAt,
);

CatalogItemModel makeItemModel({
  String id = 'item-1',
  String groupId = 'group-1',
  String name = 'Item One',
  List<String> gallery = const ['https://example.com/1.png'],
  String? imageUrl = 'https://example.com/item.png',
  bool isActive = true,
}) => CatalogItemModel(
  id: id,
  groupId: groupId,
  name: name,
  shortDescription: 'Short description',
  longDescription: 'Long description',
  imageUrl: imageUrl,
  gallery: gallery,
  sortOrder: 2,
  isActive: isActive,
  isFeatured: true,
  metadata: const {'color': 'blue'},
  createdAt: testCreatedAt,
  updatedAt: testUpdatedAt,
);

FavoriteEntity makeFavorite({
  String id = 'favorite-1',
  String userId = 'user-1',
  String catalogItemId = 'item-1',
}) => FavoriteEntity(
  id: id,
  userId: userId,
  catalogItemId: catalogItemId,
  createdAt: testCreatedAt,
  updatedAt: testUpdatedAt,
);

FavoriteModel makeFavoriteModel({
  String id = 'favorite-1',
  String userId = 'user-1',
  String catalogItemId = 'item-1',
}) => FavoriteModel(
  id: id,
  userId: userId,
  catalogItemId: catalogItemId,
  createdAt: testCreatedAt,
  updatedAt: testUpdatedAt,
);
