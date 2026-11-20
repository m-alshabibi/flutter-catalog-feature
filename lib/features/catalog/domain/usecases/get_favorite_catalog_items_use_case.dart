import '../../../../core/domain/usecases/use_case.dart';
import '../../../../core/result/result.dart';
import '../entities/catalog_item_entity.dart';
import '../entities/favorite_entity.dart';
import '../repositories/catalog_item_repository.dart';
import '../repositories/favorite_repository.dart';

class GetFavoriteCatalogItemsUseCase
    implements UseCase<List<CatalogItemEntity>, String> {
  final FavoriteRepository _favoriteRepository;
  final CatalogItemRepository _catalogItemRepository;

  GetFavoriteCatalogItemsUseCase({
    required this._favoriteRepository,
    required this._catalogItemRepository,
  });

  @override
  Future<Result<List<CatalogItemEntity>>> call(String userId) async {
    // 1. Get user's favorite records.
    final favoritesResult = await _favoriteRepository.getFavorites(userId);

    if (favoritesResult is FailureResult<List<FavoriteEntity>>) {
      return FailureResult<List<CatalogItemEntity>>(favoritesResult.failure);
    }

    final favorites = (favoritesResult as Success<List<FavoriteEntity>>).data;

    // 2. No favorites means no need to query catalog items.
    if (favorites.isEmpty) {
      return const Success<List<CatalogItemEntity>>([]);
    }

    // 3. Extract catalog item IDs.
    final catalogItemIds = favorites
        .map((favorite) => favorite.catalogItemId)
        .toSet();

    // 4. Get the actual catalog items.
    final catalogItemsResult = await _catalogItemRepository
        .getCatalogItemsByIds(catalogItemIds);

    if (catalogItemsResult is FailureResult<List<CatalogItemEntity>>) {
      return FailureResult<List<CatalogItemEntity>>(catalogItemsResult.failure);
    }

    return Success<List<CatalogItemEntity>>(
      (catalogItemsResult as Success<List<CatalogItemEntity>>).data,
    );
  }
}
