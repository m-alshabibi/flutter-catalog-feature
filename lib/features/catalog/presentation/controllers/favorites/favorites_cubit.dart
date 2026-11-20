import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/result/result.dart';
import '../../../domain/entities/catalog_item_entity.dart';
import '../../../domain/usecases/add_favorite_use_case.dart';
import '../../../domain/usecases/get_favorite_catalog_items_use_case.dart';
import '../../../domain/usecases/params/add_favorite_params.dart';
import '../../../domain/usecases/refresh_favorites_use_case.dart';
import '../../../domain/usecases/remove_favorite_use_case.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final String userId;

  final GetFavoriteCatalogItemsUseCase _getFavoriteCatalogItemsUseCase;
  final AddFavoriteUseCase _addFavoriteUseCase;
  final RemoveFavoriteUseCase _removeFavoriteUseCase;
  final RefreshFavoritesUseCase _refreshFavoritesUseCase;

  /// Prevents concurrent mutations of the same item.
  final Set<String> _updatingItemIds = {};

  FavoritesCubit({
    required this.userId,
    required this._getFavoriteCatalogItemsUseCase,
    required this._addFavoriteUseCase,
    required this._removeFavoriteUseCase,
    required this._refreshFavoritesUseCase,
  }) : super(FavoritesState());

  /// Loads local favorites first, then synchronizes with the remote source.
  Future<void> loadFavorites() async {
    if (isClosed || state.hasLoaded || state.isLoading) return;

    await _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    emit(state.copyWith(isLoading: true, clearFailure: true));

    var hasLocalData = false;

    try {
      final localResult = await _getFavoriteCatalogItemsUseCase(userId);
      if (isClosed) return;

      if (localResult is Success<List<CatalogItemEntity>>) {
        hasLocalData = true;

        _emitFavoriteItems(
          localResult.data,
          isLoading: false,
          isRefreshing: true,
        );
      }

      final refreshResult = await _refreshFavoritesUseCase(userId);
      if (isClosed) return;

      if (refreshResult is Success<void>) {
        final updatedResult = await _getFavoriteCatalogItemsUseCase(userId);
        if (isClosed) return;

        if (updatedResult is Success<List<CatalogItemEntity>>) {
          _emitFavoriteItems(updatedResult.data);
        } else if (!hasLocalData) {
          _setFailure(_failureOf(updatedResult));
        }
      } else if (!hasLocalData) {
        _setFailure(_failureOf(refreshResult));
      }
    } finally {
      if (!isClosed) {
        emit(state.copyWith(isLoading: false, isRefreshing: false));
      }
    }
  }

  /// Adds an item to the current user's favorites.
  Future<void> addFavorite(String catalogItemId) async {
    if (isClosed ||
        catalogItemId.trim().isEmpty ||
        state.isFavorite(catalogItemId) ||
        !_updatingItemIds.add(catalogItemId)) {
      return;
    }

    _updateUpdatingItems();

    try {
      final result = await _addFavoriteUseCase(
        AddFavoriteParams(userId: userId, catalogItemId: catalogItemId),
      );

      if (isClosed) return;

      if (result is Success<void>) {
        _updateFavoriteIds({...state.favoriteItemIds, catalogItemId});

        await _reloadFavoriteItems();
      } else {
        _setFailure(_failureOf(result));
      }
    } finally {
      _updatingItemIds.remove(catalogItemId);
      _updateUpdatingItems();
    }
  }

  /// Removes an item from the current user's favorites.
  Future<void> removeFavorite(String catalogItemId) async {
    if (isClosed ||
        catalogItemId.trim().isEmpty ||
        !state.isFavorite(catalogItemId) ||
        !_updatingItemIds.add(catalogItemId)) {
      return;
    }

    _updateUpdatingItems();

    try {
      final result = await _removeFavoriteUseCase(
        AddFavoriteParams(userId: userId, catalogItemId: catalogItemId),
      );

      if (isClosed) return;

      if (result is Success<void>) {
        final updatedIds = {...state.favoriteItemIds}..remove(catalogItemId);

        final updatedItems = state.favoriteItems
            .where((item) => item.id != catalogItemId)
            .toList();

        _emitFavoriteItems(updatedItems, favoriteItemIds: updatedIds);
      } else {
        _setFailure(_failureOf(result));
      }
    } finally {
      _updatingItemIds.remove(catalogItemId);
      _updateUpdatingItems();
    }
  }

  /// Toggles an item's favorite status.
  Future<void> toggleFavorite(String catalogItemId) {
    return state.isFavorite(catalogItemId)
        ? removeFavorite(catalogItemId)
        : addFavorite(catalogItemId);
  }

  /// Synchronizes favorites without discarding cached data on failure.
  Future<void> refreshFavorites() async {
    if (isClosed || state.isLoading || state.isRefreshing) return;

    if (!state.hasLoaded) {
      await loadFavorites();
      return;
    }

    emit(state.copyWith(isRefreshing: true, clearFailure: true));

    try {
      final refreshResult = await _refreshFavoritesUseCase(userId);
      if (isClosed) return;

      if (refreshResult is Success<void>) {
        final updatedResult = await _getFavoriteCatalogItemsUseCase(userId);
        if (isClosed) return;

        if (updatedResult is Success<List<CatalogItemEntity>>) {
          _emitFavoriteItems(updatedResult.data);
        } else {
          _setFailure(_failureOf(updatedResult));
        }
      } else {
        _setFailure(_failureOf(refreshResult));
      }
    } finally {
      if (!isClosed) {
        emit(state.copyWith(isRefreshing: false));
      }
    }
  }

  Future<void> _reloadFavoriteItems() async {
    final result = await _getFavoriteCatalogItemsUseCase(userId);
    if (isClosed) return;

    if (result is Success<List<CatalogItemEntity>>) {
      _emitFavoriteItems(result.data);
    } else {
      _setFailure(_failureOf(result));
    }
  }

  void _emitFavoriteItems(
    List<CatalogItemEntity> items, {
    Set<String>? favoriteItemIds,
    bool isLoading = false,
    bool isRefreshing = false,
  }) {
    if (isClosed) return;

    final itemIds = favoriteItemIds ?? items.map((item) => item.id).toSet();

    emit(
      state.copyWith(
        favoriteItems: items,
        favoriteItemIds: itemIds,
        hasLoaded: true,
        isLoading: isLoading,
        isRefreshing: isRefreshing,
        clearFailure: true,
      ),
    );
  }

  void _updateFavoriteIds(Set<String> favoriteItemIds) {
    if (isClosed) return;

    emit(
      state.copyWith(
        favoriteItemIds: favoriteItemIds,
        hasLoaded: true,
        clearFailure: true,
      ),
    );
  }

  void _updateUpdatingItems() {
    if (isClosed) return;

    emit(state.copyWith(updatingItemIds: _updatingItemIds));
  }

  void _setFailure(Failure failure) {
    if (isClosed) return;

    emit(state.copyWith(failure: failure));
  }

  Failure _failureOf<T>(Result<T> result) {
    if (result is FailureResult<T>) {
      return result.failure;
    }

    return const UnknownFailure();
  }
}
