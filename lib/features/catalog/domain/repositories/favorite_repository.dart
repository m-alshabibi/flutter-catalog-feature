import '../../../../core/result/result.dart';
import '../entities/favorite_entity.dart';

abstract interface class FavoriteRepository {
  /// Retrieves all favorites belonging to a specific user.
  Future<Result<List<FavoriteEntity>>> getFavorites(String userId);

  /// Adds a catalog item to a user's favorites.
  Future<Result<void>> addFavorite(String userId, String catalogItemId);

  /// Removes a catalog item from a user's favorites.
  Future<Result<void>> removeFavorite(String userId, String catalogItemId);

  /// Fetches the latest favorites from the remote source
  /// and updates the local cache.
  Future<Result<void>> refreshFavorites(String userId);
}
