import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/error/failures.dart';
import 'package:flutter_catalog_feature/core/result/result.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/catalog_item_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/favorite_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/repositories/catalog_item_repository.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/repositories/favorite_repository.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/get_favorite_catalog_items_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockFavoriteRepository extends Mock implements FavoriteRepository {}

class MockCatalogItemRepository extends Mock implements CatalogItemRepository {}

void main() {
  late MockFavoriteRepository favoriteRepository;
  late MockCatalogItemRepository catalogItemRepository;
  late GetFavoriteCatalogItemsUseCase useCase;

  const userId = 'user-1';

  late FavoriteEntity favorite1;
  late FavoriteEntity favorite2;

  late CatalogItemEntity item1;
  late CatalogItemEntity item2;

  setUpAll(() {
    registerFallbackValue(<String>{});
  });

  setUp(() {
    favoriteRepository = MockFavoriteRepository();
    catalogItemRepository = MockCatalogItemRepository();

    useCase = GetFavoriteCatalogItemsUseCase(
      favoriteRepository: favoriteRepository,
      catalogItemRepository: catalogItemRepository,
    );

    favorite1 = FavoriteEntity(
      id: 'favorite-1',
      userId: userId,
      catalogItemId: 'item-1',
    );

    favorite2 = FavoriteEntity(
      id: 'favorite-2',
      userId: userId,
      catalogItemId: 'item-2',
    );

    item1 = CatalogItemEntity(
      id: 'item-1',
      groupId: 'group-1',
      name: 'Flutter Development',
    );

    item2 = CatalogItemEntity(
      id: 'item-2',
      groupId: 'group-1',
      name: 'Backend Development',
    );
  });

  group('GetFavoriteCatalogItemsUseCase', () {
    test('should return favorite catalog items successfully', () async {
      // Arrange
      when(() => favoriteRepository.getFavorites(userId)).thenAnswer(
        (_) async => Success<List<FavoriteEntity>>([favorite1, favorite2]),
      );

      when(() => catalogItemRepository.getCatalogItemsByIds(any())).thenAnswer(
        (_) async => Success<List<CatalogItemEntity>>([item1, item2]),
      );

      // Act
      final result = await useCase.call(userId);

      // Assert
      expect(result, isA<Success<List<CatalogItemEntity>>>());

      final data = (result as Success<List<CatalogItemEntity>>).data;

      expect(data, [item1, item2]);

      verify(() => favoriteRepository.getFavorites(userId)).called(1);

      final capturedIds =
          verify(() => catalogItemRepository.getCatalogItemsByIds(captureAny()))
                  .captured
                  .single
              as Set<String>;

      expect(capturedIds, {'item-1', 'item-2'});

      verifyNoMoreInteractions(favoriteRepository);
      verifyNoMoreInteractions(catalogItemRepository);
    });

    test('should return failure when getting favorites fails', () async {
      // Arrange
      const failure = NetworkFailure();

      when(() => favoriteRepository.getFavorites(userId)).thenAnswer(
        (_) async => const FailureResult<List<FavoriteEntity>>(failure),
      );

      // Act
      final result = await useCase.call(userId);

      // Assert
      expect(result, isA<FailureResult<List<CatalogItemEntity>>>());

      final resultFailure =
          (result as FailureResult<List<CatalogItemEntity>>).failure;

      expect(resultFailure, isA<NetworkFailure>());

      verify(() => favoriteRepository.getFavorites(userId)).called(1);

      verifyNever(() => catalogItemRepository.getCatalogItemsByIds(any()));

      verifyNoMoreInteractions(favoriteRepository);
      verifyNoMoreInteractions(catalogItemRepository);
    });

    test('should return failure when getting catalog items fails', () async {
      // Arrange
      const failure = ServerFailure('Failed to load catalog items.');

      when(() => favoriteRepository.getFavorites(userId))
          .thenAnswer((_) async => Success<List<FavoriteEntity>>([favorite1]));

      when(() => catalogItemRepository.getCatalogItemsByIds(any())).thenAnswer(
        (_) async => const FailureResult<List<CatalogItemEntity>>(failure),
      );

      // Act
      final result = await useCase.call(userId);

      // Assert
      expect(result, isA<FailureResult<List<CatalogItemEntity>>>());

      final resultFailure =
          (result as FailureResult<List<CatalogItemEntity>>).failure;

      expect(resultFailure, isA<ServerFailure>());

      verify(() => favoriteRepository.getFavorites(userId)).called(1);

      verify(() => catalogItemRepository.getCatalogItemsByIds(any())).called(1);

      verifyNoMoreInteractions(favoriteRepository);
      verifyNoMoreInteractions(catalogItemRepository);
    });

    test('should return empty list without querying catalog when no favorites exist', () async {
      // Arrange
      when(() => favoriteRepository.getFavorites(userId))
          .thenAnswer((_) async => const Success<List<FavoriteEntity>>([]));

      // Act
      final result = await useCase.call(userId);

      // Assert
      expect(result, isA<Success<List<CatalogItemEntity>>>());

      final data = (result as Success<List<CatalogItemEntity>>).data;

      expect(data, isEmpty);

      verify(() => favoriteRepository.getFavorites(userId)).called(1);

      verifyNever(() => catalogItemRepository.getCatalogItemsByIds(any()));

      verifyNoMoreInteractions(favoriteRepository);
      verifyNoMoreInteractions(catalogItemRepository);
    });
  });
}
