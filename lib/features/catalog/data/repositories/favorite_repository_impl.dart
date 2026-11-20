import 'dart:async';
import 'dart:convert';

import '../../../../core/error/exception_to_failure_mapper.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/catalog_item_entity.dart';
import '../../domain/entities/favorite_entity.dart';
import '../../domain/repositories/catalog_item_repository.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../datasources/local/favorite_local_data_source.dart';
import '../datasources/remote/favorite_remote_data_source.dart';
import '../models/favorite_model.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteLocalDataSource _localDataSource;
  final FavoriteRemoteDataSource _remoteDataSource;
  final CatalogItemRepository _catalogItemRepository;

  FavoriteRepositoryImpl({
    required FavoriteLocalDataSource localDataSource,
    required FavoriteRemoteDataSource remoteDataSource,
    required CatalogItemRepository catalogItemRepository,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource,
       _catalogItemRepository = catalogItemRepository;

  @override
  Future<Result<List<FavoriteEntity>>> getFavorites(String userId) async {
    try {
      final favorites = await _localDataSource.getFavorites(userId);

      return Success<List<FavoriteEntity>>(favorites);
    } on AppException catch (exception) {
      return FailureResult(ExceptionToFailureMapper.map(exception));
    } catch (error) {
      return FailureResult(UnknownFailure(error.toString()));
    }
  }

  @override
  Future<Result<void>> addFavorite(String userId, String catalogItemId) async {
    try {
      final favorite = FavoriteModel(
        id: _generateFavoriteId(userId, catalogItemId),
        userId: userId,
        catalogItemId: catalogItemId,
      );

      await _localDataSource.saveFavorite(favorite);
    } on AppException catch (exception) {
      return FailureResult(ExceptionToFailureMapper.map(exception));
    } catch (error) {
      return FailureResult(UnknownFailure(error.toString()));
    }

    // Local save succeeded. Remote sync is best-effort.
    await _trySyncPendingFavorites(userId);

    return const Success(null);
  }

  @override
  Future<Result<void>> removeFavorite(
    String userId,
    String catalogItemId,
  ) async {
    try {
      await _localDataSource.removeFavorite(userId, catalogItemId);
    } on AppException catch (exception) {
      return FailureResult(ExceptionToFailureMapper.map(exception));
    } catch (error) {
      return FailureResult(UnknownFailure(error.toString()));
    }

    // Local removal succeeded. Remote sync is best-effort.
    await _trySyncPendingFavorites(userId);

    return const Success(null);
  }

  @override
  Future<Result<void>> refreshFavorites(String userId) async {
    try {
      // Push pending local operations first.
      await _syncPendingFavorites(userId);

      // Fetch the latest remote state.
      final remoteFavorites = await _remoteDataSource.getFavorites(userId);

      // Favorites reference catalog items through a local foreign key.
      // Cache missing catalog items (and their parent groups) first.
      final catalogItemIds = remoteFavorites
          .where((favorite) => favorite.userId == userId)
          .map((favorite) => favorite.catalogItemId)
          .toSet();

      if (catalogItemIds.isNotEmpty) {
        final catalogItemsResult = await _catalogItemRepository
            .getCatalogItemsByIds(catalogItemIds);

        if (catalogItemsResult
            is FailureResult<List<CatalogItemEntity>>) {
          return FailureResult<void>(catalogItemsResult.failure);
        }

        final cachedItemIds =
            (catalogItemsResult as Success<List<CatalogItemEntity>>)
                .data
                .map((item) => item.id)
                .toSet();

        if (!cachedItemIds.containsAll(catalogItemIds)) {
          return const FailureResult<void>(
            NotFoundFailure(
              'One or more catalog items referenced by favorites were not found.',
            ),
          );
        }
      }

      await _localDataSource.syncFavorites(
        userId: userId,
        favorites: remoteFavorites,
      );

      return const Success<void>(null);
    } on AppException catch (exception) {
      return FailureResult(ExceptionToFailureMapper.map(exception));
    } catch (error) {
      return FailureResult(UnknownFailure(error.toString()));
    }
  }

  Future<void> _trySyncPendingFavorites(String userId) async {
    try {
      await _syncPendingFavorites(userId);
    } catch (_) {
      // Keep pending operations locally for a later retry.
    }
  }

  final Map<String, Future<void>> _syncLocks = {};

  Future<void> _syncPendingFavorites(String userId) async {
    final previousSync = _syncLocks[userId] ?? Future<void>.value();

    final completer = Completer<void>();
    final currentSync = completer.future;

    _syncLocks[userId] = currentSync;

    try {
      await previousSync;

      final pendingOperations = await _localDataSource.getPendingFavorites(
        userId,
      );

      for (final operation in pendingOperations) {
        final favorite = operation.favorite;

        if (operation.isDeleted) {
          await _remoteDataSource.removeFavorite(
            favorite.userId,
            favorite.catalogItemId,
          );
        } else {
          await _remoteDataSource.addFavorite(
            favorite.userId,
            favorite.catalogItemId,
          );
        }

        await _localDataSource.markFavoriteAsSynced(
          userId: favorite.userId,
          catalogItemId: favorite.catalogItemId,
          wasDeleted: operation.isDeleted,
        );
      }
    } finally {
      completer.complete();

      if (identical(_syncLocks[userId], currentSync)) {
        _syncLocks.remove(userId);
      }
    }
  }

  String _generateFavoriteId(String userId, String catalogItemId) {
    return base64Url.encode(utf8.encode('$userId:$catalogItemId'));
  }
}
