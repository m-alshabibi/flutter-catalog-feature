import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/catalog/catalog_cubit.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/catalog_item_details/catalog_item_details_cubit.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/favorites/favorites_cubit.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/add_favorite_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/get_catalog_item_by_id_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/get_catalog_items_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/get_favorite_catalog_items_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/get_groups_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/refresh_catalog_items_by_group_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/refresh_favorites_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/refresh_groups_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/remove_favorite_use_case.dart';
import 'fake_repositories.dart';

CatalogCubit createCatalogCubit({
  FakeGroupRepository? groups,
  FakeCatalogItemRepository? items,
}) {
  final groupRepository = groups ?? FakeGroupRepository();
  final itemRepository = items ?? FakeCatalogItemRepository();
  return CatalogCubit(
    getGroupsUseCase: GetGroupsUseCase(groupRepository),
    refreshGroupsUseCase: RefreshGroupsUseCase(groupRepository),
    getCatalogItemsUseCase: GetCatalogItemsUseCase(itemRepository),
    refreshCatalogItemsByGroupUseCase: RefreshCatalogItemsByGroupUseCase(itemRepository),
  );
}

FavoritesCubit createFavoritesCubit({
  String userId = 'user-1',
  FakeFavoriteRepository? favorites,
  FakeCatalogItemRepository? items,
}) {
  final favoriteRepository = favorites ?? FakeFavoriteRepository();
  final itemRepository = items ?? FakeCatalogItemRepository();
  return FavoritesCubit(
    userId: userId,
    getFavoriteCatalogItemsUseCase: GetFavoriteCatalogItemsUseCase(
      favoriteRepository: favoriteRepository,
      catalogItemRepository: itemRepository,
    ),
    addFavoriteUseCase: AddFavoriteUseCase(favoriteRepository),
    removeFavoriteUseCase: RemoveFavoriteUseCase(favoriteRepository),
    refreshFavoritesUseCase: RefreshFavoritesUseCase(favoriteRepository),
  );
}

CatalogItemDetailsCubit createDetailsCubit({
  String itemId = 'item-1',
  required FakeCatalogItemRepository items,
}) => CatalogItemDetailsCubit(
  getCatalogItemByIdUseCase: GetCatalogItemByIdUseCase(items),
  itemId: itemId,
);
