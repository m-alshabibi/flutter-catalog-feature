import '../../../../../core/error/failures.dart';
import '../../../domain/entities/catalog_item_entity.dart';
import '../base/base_load_state.dart';

class FavoritesState extends BaseLoadState {
  /// Full catalog items currently in the user's favorites.
  final List<CatalogItemEntity> favoriteItems;

  /// IDs used for fast favorite-status checks.
  final Set<String> favoriteItemIds;

  /// Tracks favorite operations independently by catalog item ID.
  final Set<String> updatingItemIds;

  FavoritesState({
    List<CatalogItemEntity> favoriteItems = const [],
    Set<String> favoriteItemIds = const {},
    super.hasLoaded = false,
    super.isLoading = false,
    super.isRefreshing = false,
    Set<String> updatingItemIds = const {},
    super.failure,
  }) : favoriteItems = List.unmodifiable(favoriteItems),
       favoriteItemIds = Set.unmodifiable(favoriteItemIds),
       updatingItemIds = Set.unmodifiable(updatingItemIds);

  bool isFavorite(String catalogItemId) {
    return favoriteItemIds.contains(catalogItemId);
  }

  bool isUpdating(String catalogItemId) {
    return updatingItemIds.contains(catalogItemId);
  }

  FavoritesState copyWith({
    List<CatalogItemEntity>? favoriteItems,
    Set<String>? favoriteItemIds,
    bool? hasLoaded,
    bool? isLoading,
    bool? isRefreshing,
    Set<String>? updatingItemIds,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return FavoritesState(
      favoriteItems: favoriteItems ?? this.favoriteItems,
      favoriteItemIds: favoriteItemIds ?? this.favoriteItemIds,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      updatingItemIds: updatingItemIds ?? this.updatingItemIds,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }
}
