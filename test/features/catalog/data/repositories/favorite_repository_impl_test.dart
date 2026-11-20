import 'package:flutter_catalog_feature/core/error/exceptions.dart';
import 'package:flutter_catalog_feature/core/error/failures.dart';
import 'package:flutter_catalog_feature/core/result/result.dart';
import 'package:flutter_catalog_feature/features/catalog/data/datasources/local/favorite_local_data_source.dart';
import 'package:flutter_catalog_feature/features/catalog/data/datasources/remote/favorite_remote_data_source.dart';
import 'package:flutter_catalog_feature/features/catalog/data/models/favorite_model.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/catalog_item_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/repositories/catalog_item_repository.dart';
import 'package:flutter_catalog_feature/features/catalog/data/repositories/favorite_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFavoriteLocalDataSource extends Mock
    implements FavoriteLocalDataSource {}

class MockFavoriteRemoteDataSource extends Mock
    implements FavoriteRemoteDataSource {}

class MockCatalogItemRepository extends Mock
    implements CatalogItemRepository {}

void main() {
  late MockFavoriteLocalDataSource localDataSource;
  late MockFavoriteRemoteDataSource remoteDataSource;
  late MockCatalogItemRepository catalogItemRepository;
  late FavoriteRepositoryImpl repository;
  setUpAll(() {
    registerFallbackValue(
      FavoriteModel(
        id: 'fallback-id',
        userId: 'fallback-user',
        catalogItemId: 'fallback-item',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    );
  });
  setUp(() {
    localDataSource = MockFavoriteLocalDataSource();
    remoteDataSource = MockFavoriteRemoteDataSource();
    catalogItemRepository = MockCatalogItemRepository();
    repository = FavoriteRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
      catalogItemRepository: catalogItemRepository,
    );
  });

  group('getFavorites', () {
    test('should return local favorites successfully', () async {
      final favorites = [
        FavoriteModel(
          id: 'favorite-1',
          userId: 'user-1',
          catalogItemId: 'item-1',
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      ];

      when(() => localDataSource.getFavorites('user-1'))
          .thenAnswer((_) async => favorites);

      final result = await repository.getFavorites('user-1');

      expect(result, isA<Success>());
      expect((result as Success).data, favorites);

      verify(() => localDataSource.getFavorites('user-1')).called(1);
      verifyNever(() => remoteDataSource.getFavorites(any()));
    });

    test('should map AppException to FailureResult', () async {
      when(() => localDataSource.getFavorites('user-1'))
          .thenThrow(const CacheException());

      final result = await repository.getFavorites('user-1');

      expect(result, isA<FailureResult>());
      expect((result as FailureResult).failure, isA<CacheFailure>());
    });

    test('should return UnknownFailure for unexpected errors', () async {
      when(() => localDataSource.getFavorites('user-1'))
          .thenThrow(Exception('Unexpected error'));

      final result = await repository.getFavorites('user-1');

      expect(result, isA<FailureResult>());
      expect((result as FailureResult).failure, isA<UnknownFailure>());
    });
  });

  group('addFavorite', () {
    test('should save locally then synchronize remotely', () async {
      when(() => localDataSource.saveFavorite(any())).thenAnswer((_) async {});

      when(() => localDataSource.getPendingFavorites('user-1'))
          .thenAnswer((_) async => []);

      final result = await repository.addFavorite('user-1', 'item-1');

      expect(result, isA<Success>());

      verify(() => localDataSource.saveFavorite(any())).called(1);
      verify(() => localDataSource.getPendingFavorites('user-1')).called(1);
    });

    test(
      'should keep local success when remote synchronization fails',
      () async {
        final favorite = FavoriteModel(
          id: 'favorite-1',
          userId: 'user-1',
          catalogItemId: 'item-1',
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        );

        when(() => localDataSource.saveFavorite(any()))
            .thenAnswer((_) async {});

        when(() => localDataSource.getPendingFavorites('user-1')).thenAnswer(
          (_) async => [
            PendingFavoriteOperation(favorite: favorite, isDeleted: false),
          ],
        );

        when(() => remoteDataSource.addFavorite('user-1', 'item-1'))
            .thenThrow(const NetworkException());

        final result = await repository.addFavorite('user-1', 'item-1');

        expect(result, isA<Success>());

        verifyNever(
          () => localDataSource.markFavoriteAsSynced(
            userId: any(named: 'userId'),
            catalogItemId: any(named: 'catalogItemId'),
            wasDeleted: any(named: 'wasDeleted'),
          ),
        );
      },
    );

    test('should return failure when local save fails', () async {
      when(() => localDataSource.saveFavorite(any()))
          .thenThrow(const CacheException());

      final result = await repository.addFavorite('user-1', 'item-1');

      expect(result, isA<FailureResult>());
      expect((result as FailureResult).failure, isA<CacheFailure>());

      verifyNever(() => localDataSource.getPendingFavorites(any()));
    });
  });

  group('removeFavorite', () {
    test('should remove locally then synchronize pending operations', () async {
      when(() => localDataSource.removeFavorite('user-1', 'item-1'))
          .thenAnswer((_) async {});

      when(() => localDataSource.getPendingFavorites('user-1'))
          .thenAnswer((_) async => []);

      final result = await repository.removeFavorite('user-1', 'item-1');

      expect(result, isA<Success>());

      verify(() => localDataSource.removeFavorite('user-1', 'item-1'))
          .called(1);

      verify(() => localDataSource.getPendingFavorites('user-1')).called(1);
    });

    test('should keep local success when remote removal fails', () async {
      final favorite = FavoriteModel(
        id: 'favorite-1',
        userId: 'user-1',
        catalogItemId: 'item-1',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

      when(() => localDataSource.removeFavorite('user-1', 'item-1'))
          .thenAnswer((_) async {});

      when(() => localDataSource.getPendingFavorites('user-1')).thenAnswer(
        (_) async => [
          PendingFavoriteOperation(favorite: favorite, isDeleted: true),
        ],
      );

      when(() => remoteDataSource.removeFavorite('user-1', 'item-1'))
          .thenThrow(const NetworkException());

      final result = await repository.removeFavorite('user-1', 'item-1');

      expect(result, isA<Success>());

      verifyNever(
        () => localDataSource.markFavoriteAsSynced(
          userId: any(named: 'userId'),
          catalogItemId: any(named: 'catalogItemId'),
          wasDeleted: any(named: 'wasDeleted'),
        ),
      );
    });

    test('should return failure when local removal fails', () async {
      when(() => localDataSource.removeFavorite('user-1', 'item-1'))
          .thenThrow(const CacheException());

      final result = await repository.removeFavorite('user-1', 'item-1');

      expect(result, isA<FailureResult>());
      expect((result as FailureResult).failure, isA<CacheFailure>());

      verifyNever(() => localDataSource.getPendingFavorites(any()));
    });
  });

  group('refreshFavorites', () {
    test(
      'should synchronize pending operations then refresh local data',
      () async {
        final remoteFavorites = [
          FavoriteModel(
            id: 'favorite-1',
            userId: 'user-1',
            catalogItemId: 'item-1',
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        ];

        when(() => localDataSource.getPendingFavorites('user-1'))
            .thenAnswer((_) async => []);

        when(() => remoteDataSource.getFavorites('user-1'))
            .thenAnswer((_) async => remoteFavorites);

        final catalogItem = CatalogItemEntity(
          id: 'item-1',
          groupId: 'group-1',
          name: 'Item 1',
        );

        when(() => catalogItemRepository.getCatalogItemsByIds({'item-1'}))
            .thenAnswer((_) async => Success<List<CatalogItemEntity>>([catalogItem]));

        when(
          () => localDataSource.syncFavorites(
            userId: 'user-1',
            favorites: remoteFavorites,
          ),
        ).thenAnswer((_) async {});

        final result = await repository.refreshFavorites('user-1');

        expect(result, isA<Success>());

        verifyInOrder([
          () => localDataSource.getPendingFavorites('user-1'),
          () => remoteDataSource.getFavorites('user-1'),
          () => catalogItemRepository.getCatalogItemsByIds({'item-1'}),
          () => localDataSource.syncFavorites(
            userId: 'user-1',
            favorites: remoteFavorites,
          ),
        ]);
      },
    );

    test(
      'should mark pending addition as synced after remote success',
      () async {
        final favorite = FavoriteModel(
          id: 'favorite-1',
          userId: 'user-1',
          catalogItemId: 'item-1',
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        );

        when(() => localDataSource.getPendingFavorites('user-1')).thenAnswer(
          (_) async => [
            PendingFavoriteOperation(favorite: favorite, isDeleted: false),
          ],
        );

        when(() => remoteDataSource.addFavorite('user-1', 'item-1'))
            .thenAnswer((_) async {});

        when(
          () => localDataSource.markFavoriteAsSynced(
            userId: 'user-1',
            catalogItemId: 'item-1',
            wasDeleted: false,
          ),
        ).thenAnswer((_) async {});

        when(() => remoteDataSource.getFavorites('user-1'))
            .thenAnswer((_) async => []);

        when(() => catalogItemRepository.getCatalogItemsByIds(<String>{}))
            .thenAnswer((_) async => Success<List<CatalogItemEntity>>([]));

        when(
          () => localDataSource.syncFavorites(userId: 'user-1', favorites: []),
        ).thenAnswer((_) async {});

        final result = await repository.refreshFavorites('user-1');

        expect(result, isA<Success>());

        verify(
          () => localDataSource.markFavoriteAsSynced(
            userId: 'user-1',
            catalogItemId: 'item-1',
            wasDeleted: false,
          ),
        ).called(1);
      },
    );

    test('should return failure when remote refresh fails', () async {
      when(() => localDataSource.getPendingFavorites('user-1'))
          .thenAnswer((_) async => []);

      when(() => remoteDataSource.getFavorites('user-1'))
          .thenThrow(const NetworkException());

      final result = await repository.refreshFavorites('user-1');

      expect(result, isA<FailureResult>());
      expect((result as FailureResult).failure, isA<NetworkFailure>());

      verifyNever(
        () => localDataSource.syncFavorites(
          userId: any(named: 'userId'),
          favorites: any(named: 'favorites'),
        ),
      );
    });
  });
}
