import '../../../../core/domain/usecases/use_case.dart';
import '../../../../core/result/result.dart';
import '../entities/catalog_item_entity.dart';
import '../entities/favorite_entity.dart';
import '../models/catalog_item_with_favorite.dart';
import '../repositories/catalog_item_repository.dart';
import '../repositories/favorite_repository.dart';

class GetCatalogItemsWithFavoriteStatusUseCase
    implements UseCase<Map<String, List<CatalogItemWithFavorite>>, String> {
  final CatalogItemRepository _catalogItemRepository;
  final FavoriteRepository _favoriteRepository;

  GetCatalogItemsWithFavoriteStatusUseCase({
    required this._catalogItemRepository,
    required this._favoriteRepository,
  });

  @override
  Future<Result<Map<String, List<CatalogItemWithFavorite>>>> call(
    String userId,
  ) async {
    // Fetch catalog items and favorites in parallel.
    final results = await Future.wait([
      _catalogItemRepository.getAllCatalogItems(),
      _favoriteRepository.getFavorites(userId),
    ]);

    final catalogResult =
        results[0] as Result<Map<String, List<CatalogItemEntity>>>;

    final favoritesResult = results[1] as Result<List<FavoriteEntity>>;

    // Handle catalog failure.
    if (catalogResult is FailureResult<Map<String, List<CatalogItemEntity>>>) {
      return FailureResult<Map<String, List<CatalogItemWithFavorite>>>(
        catalogResult.failure,
      );
    }

    // Handle favorites failure.
    if (favoritesResult is FailureResult<List<FavoriteEntity>>) {
      return FailureResult<Map<String, List<CatalogItemWithFavorite>>>(
        favoritesResult.failure,
      );
    }

    final catalogItemsByGroup =
        (catalogResult as Success<Map<String, List<CatalogItemEntity>>>).data;

    final favorites = (favoritesResult as Success<List<FavoriteEntity>>).data;

    // Create a set for efficient favorite lookup.
    final favoriteIds = favorites
        .map((favorite) => favorite.catalogItemId)
        .toSet();

    // Combine catalog items with their favorite status.
    final result = catalogItemsByGroup.map((groupId, items) {
      final itemsWithFavoriteStatus = items.map((item) {
        return CatalogItemWithFavorite(
          catalogItem: item,
          isFavorite: favoriteIds.contains(item.id),
        );
      }).toList();

      return MapEntry(groupId, itemsWithFavoriteStatus);
    });

    return Success<Map<String, List<CatalogItemWithFavorite>>>(result);
  }
}
