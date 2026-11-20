import 'package:drift/drift.dart';

import '../../models/favorite_model.dart';
import 'database/app_database.dart';

class PendingFavoriteOperation {
  final FavoriteModel favorite;
  final bool isDeleted;

  const PendingFavoriteOperation({
    required this.favorite,
    required this.isDeleted,
  });
}

abstract interface class FavoriteLocalDataSource {
  Future<List<FavoriteModel>> getFavorites(String userId);

  Future<void> saveFavorite(FavoriteModel favorite);

  Future<void> syncFavorites({
    required String userId,
    required List<FavoriteModel> favorites,
  });

  Future<void> removeFavorite(String userId, String catalogItemId);

  Future<List<PendingFavoriteOperation>> getPendingFavorites(String userId);

  Future<void> markFavoriteAsSynced({
    required String userId,
    required String catalogItemId,
    required bool wasDeleted,
  });
}

class FavoriteLocalDataSourceImpl implements FavoriteLocalDataSource {
  final AppDatabase _database;

  FavoriteLocalDataSourceImpl(this._database);

  @override
  Future<List<FavoriteModel>> getFavorites(String userId) async {
    final query = _database.select(_database.favoritesTable)
      ..where(
        (table) => table.userId.equals(userId) & table.isDeleted.equals(false),
      )
      ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]);

    final rows = await query.get();

    return rows.map(_mapToModel).toList();
  }

  @override
  Future<void> saveFavorite(FavoriteModel favorite) async {
    await _database.transaction(() async {
      final existing =
          await (_database.select(_database.favoritesTable)..where(
                (table) =>
                    table.userId.equals(favorite.userId) &
                    table.catalogItemId.equals(favorite.catalogItemId),
              ))
              .getSingleOrNull();

      if (existing != null) {
        // An active favorite already exists. Do not create
        // another pending operation.
        if (!existing.isDeleted) return;

        // Re-adding a deleted favorite creates a pending addition.
        // Preserve the existing local ID.
        await (_database.update(_database.favoritesTable)..where(
              (table) =>
                  table.userId.equals(favorite.userId) &
                  table.catalogItemId.equals(favorite.catalogItemId),
            ))
            .write(
              FavoritesTableCompanion(
                updatedAt: Value(favorite.updatedAt),
                isSynced: const Value(false),
                isDeleted: const Value(false),
              ),
            );

        return;
      }

      await _database
          .into(_database.favoritesTable)
          .insert(
            FavoritesTableCompanion.insert(
              id: favorite.id,
              userId: favorite.userId,
              catalogItemId: favorite.catalogItemId,
              createdAt: favorite.createdAt,
              updatedAt: favorite.updatedAt,
              isSynced: const Value(false),
              isDeleted: const Value(false),
            ),
          );
    });
  }

  @override
  Future<void> syncFavorites({
    required String userId,
    required List<FavoriteModel> favorites,
  }) async {
    final userFavorites = favorites
        .where((favorite) => favorite.userId == userId)
        .toList();
    final remoteItemIds = userFavorites
        .map((favorite) => favorite.catalogItemId)
        .toSet();

    await _database.transaction(() async {
      for (final favorite in userFavorites) {
        final existing =
            await (_database.select(_database.favoritesTable)..where(
                  (table) =>
                      table.userId.equals(userId) &
                      table.catalogItemId.equals(favorite.catalogItemId),
                ))
                .getSingleOrNull();

        // Pending local changes always take precedence over a remote snapshot.
        if (existing != null && !existing.isSynced) {
          continue;
        }

        if (existing != null) {
          await (_database.update(_database.favoritesTable)..where(
                (table) =>
                    table.userId.equals(userId) &
                    table.catalogItemId.equals(favorite.catalogItemId),
              ))
              .write(
                FavoritesTableCompanion(
                  createdAt: Value(favorite.createdAt),
                  updatedAt: Value(favorite.updatedAt),
                  isSynced: const Value(true),
                  isDeleted: const Value(false),
                ),
              );
        } else {
          await _database.into(_database.favoritesTable).insert(
            FavoritesTableCompanion.insert(
              id: favorite.id,
              userId: userId,
              catalogItemId: favorite.catalogItemId,
              createdAt: favorite.createdAt,
              updatedAt: favorite.updatedAt,
              isSynced: const Value(true),
              isDeleted: const Value(false),
            ),
          );
        }
      }

      // Remove only synchronized records that disappeared from the remote
      // snapshot. Pending additions and deletion tombstones remain untouched.
      final deleteQuery = _database.delete(_database.favoritesTable)
        ..where((table) {
          final belongsToUser =
              table.userId.equals(userId) & table.isSynced.equals(true);

          return remoteItemIds.isEmpty
              ? belongsToUser
              : belongsToUser & table.catalogItemId.isNotIn(remoteItemIds);
        });

      await deleteQuery.go();
    });
  }

  @override
  Future<void> removeFavorite(String userId, String catalogItemId) async {
    await _database.transaction(() async {
      final query = _database.select(_database.favoritesTable)
        ..where(
          (table) =>
              table.userId.equals(userId) &
              table.catalogItemId.equals(catalogItemId),
        );

      final favorite = await query.getSingleOrNull();

      if (favorite == null) return;

      // Keep the record as a pending deletion, even if its
      // addition has not been synchronized yet.
      await (_database.update(_database.favoritesTable)..where(
            (table) =>
                table.userId.equals(userId) &
                table.catalogItemId.equals(catalogItemId),
          ))
          .write(
            FavoritesTableCompanion(
              updatedAt: Value(DateTime.now()),
              isSynced: const Value(false),
              isDeleted: const Value(true),
            ),
          );
    });
  }

  @override
  Future<List<PendingFavoriteOperation>> getPendingFavorites(
    String userId,
  ) async {
    final query = _database.select(_database.favoritesTable)
      ..where(
        (table) => table.userId.equals(userId) & table.isSynced.equals(false),
      )
      ..orderBy([(table) => OrderingTerm.asc(table.id)]);

    final rows = await query.get();

    return rows.map((row) {
      return PendingFavoriteOperation(
        favorite: _mapToModel(row),
        isDeleted: row.isDeleted,
      );
    }).toList();
  }

  @override
  Future<void> markFavoriteAsSynced({
    required String userId,
    required String catalogItemId,
    required bool wasDeleted,
  }) async {
    if (wasDeleted) {
      // لا نحذف إلا سجل الحذف الذي لا يزال معلقًا.
      await (_database.delete(_database.favoritesTable)..where(
            (table) =>
                table.userId.equals(userId) &
                table.catalogItemId.equals(catalogItemId) &
                table.isSynced.equals(false) &
                table.isDeleted.equals(true),
          ))
          .go();
    } else {
      // لا نؤكد الإضافة إذا تغيرت حالتها أثناء طلب الشبكة.
      await (_database.update(_database.favoritesTable)..where(
            (table) =>
                table.userId.equals(userId) &
                table.catalogItemId.equals(catalogItemId) &
                table.isSynced.equals(false) &
                table.isDeleted.equals(false),
          ))
          .write(const FavoritesTableCompanion(isSynced: Value(true)));
    }
  }

  FavoriteModel _mapToModel(FavoritesTableData row) {
    return FavoriteModel(
      id: row.id,
      userId: row.userId,
      catalogItemId: row.catalogItemId,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
