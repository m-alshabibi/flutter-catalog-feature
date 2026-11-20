import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/error/failures.dart';
import 'package:flutter_catalog_feature/core/result/result.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/catalog_item_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/favorite_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/models/catalog_item_with_favorite.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/repositories/catalog_item_repository.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/repositories/favorite_repository.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/get_catalog_items_with_favorite_status_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockCatalogItemRepository extends Mock implements CatalogItemRepository {}

class MockFavoriteRepository extends Mock implements FavoriteRepository {}

void main() {
  late MockCatalogItemRepository catalogItemRepository;
  late MockFavoriteRepository favoriteRepository;

  late GetCatalogItemsWithFavoriteStatusUseCase useCase;

  const userId = 'user-1';

  late CatalogItemEntity item1;
  late CatalogItemEntity item2;
  late CatalogItemEntity item3;

  late FavoriteEntity favorite1;
  late FavoriteEntity favorite2;

  setUp(() {
    catalogItemRepository = MockCatalogItemRepository();
    favoriteRepository = MockFavoriteRepository();

    useCase = GetCatalogItemsWithFavoriteStatusUseCase(
      catalogItemRepository: catalogItemRepository,
      favoriteRepository: favoriteRepository,
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

    item3 = CatalogItemEntity(
      id: 'item-3',
      groupId: 'group-2',
      name: 'UI Design',
    );

    favorite1 = FavoriteEntity(
      id: 'favorite-1',
      userId: userId,
      catalogItemId: 'item-1',
    );

    favorite2 = FavoriteEntity(
      id: 'favorite-2',
      userId: userId,
      catalogItemId: 'item-3',
    );
  });

  group('GetCatalogItemsWithFavoriteStatusUseCase', () {
    test('should return catalog items with correct favorite status', () async {
      // Arrange
      when(() => catalogItemRepository.getAllCatalogItems()).thenAnswer(
        (_) async => Success<Map<String, List<CatalogItemEntity>>>({
          'group-1': [item1, item2],
          'group-2': [item3],
        }),
      );

      when(() => favoriteRepository.getFavorites(userId)).thenAnswer(
        (_) async => Success<List<FavoriteEntity>>([favorite1, favorite2]),
      );

      // Act
      final result = await useCase.call(userId);

      // Assert
      expect(
        result,
        isA<Success<Map<String, List<CatalogItemWithFavorite>>>>(),
      );

      final data =
          (result as Success<Map<String, List<CatalogItemWithFavorite>>>).data;

      expect(data.keys, {'group-1', 'group-2'});

      expect(data['group-1'], hasLength(2));
      expect(data['group-1']![0].catalogItem, item1);
      expect(data['group-1']![0].isFavorite, isTrue);

      expect(data['group-1']![1].catalogItem, item2);
      expect(data['group-1']![1].isFavorite, isFalse);

      expect(data['group-2']![0].catalogItem, item3);
      expect(data['group-2']![0].isFavorite, isTrue);

      verify(() => catalogItemRepository.getAllCatalogItems()).called(1);
      verify(() => favoriteRepository.getFavorites(userId)).called(1);

      verifyNoMoreInteractions(catalogItemRepository);
      verifyNoMoreInteractions(favoriteRepository);
    });

    test('should return failure when getting catalog items fails', () async {
      // Arrange
      const failure = NetworkFailure();

      when(() => catalogItemRepository.getAllCatalogItems()).thenAnswer(
        (_) async =>
            const FailureResult<Map<String, List<CatalogItemEntity>>>(failure),
      );

      when(() => favoriteRepository.getFavorites(userId))
          .thenAnswer((_) async => const Success<List<FavoriteEntity>>([]));

      // Act
      final result = await useCase.call(userId);

      // Assert
      expect(
        result,
        isA<FailureResult<Map<String, List<CatalogItemWithFavorite>>>>(),
      );

      final resultFailure =
          (result as FailureResult<Map<String, List<CatalogItemWithFavorite>>>)
              .failure;

      expect(resultFailure, isA<NetworkFailure>());

      verify(() => catalogItemRepository.getAllCatalogItems()).called(1);
      verify(() => favoriteRepository.getFavorites(userId)).called(1);
    });

    test('should return failure when getting favorites fails', () async {
      // Arrange
      const failure = ServerFailure('Failed to load favorites.');

      when(() => catalogItemRepository.getAllCatalogItems()).thenAnswer(
        (_) async => Success<Map<String, List<CatalogItemEntity>>>({
          'group-1': [item1],
        }),
      );

      when(() => favoriteRepository.getFavorites(userId)).thenAnswer(
        (_) async => const FailureResult<List<FavoriteEntity>>(failure),
      );

      // Act
      final result = await useCase.call(userId);

      // Assert
      expect(
        result,
        isA<FailureResult<Map<String, List<CatalogItemWithFavorite>>>>(),
      );

      final resultFailure =
          (result as FailureResult<Map<String, List<CatalogItemWithFavorite>>>)
              .failure;

      expect(resultFailure, isA<ServerFailure>());

      verify(() => catalogItemRepository.getAllCatalogItems()).called(1);
      verify(() => favoriteRepository.getFavorites(userId)).called(1);
    });

    test(
      'should mark all items as not favorite when favorites are empty',
      () async {
        // Arrange
        when(() => catalogItemRepository.getAllCatalogItems()).thenAnswer(
          (_) async => Success<Map<String, List<CatalogItemEntity>>>({
            'group-1': [item1, item2],
          }),
        );

        when(() => favoriteRepository.getFavorites(userId))
            .thenAnswer((_) async => const Success<List<FavoriteEntity>>([]));

        // Act
        final result = await useCase.call(userId);

        // Assert
        final data =
            (result as Success<Map<String, List<CatalogItemWithFavorite>>>)
                .data;

        expect(data['group-1']!.every((item) => !item.isFavorite), isTrue);
      },
    );

    test('should return empty map when catalog is empty', () async {
      // Arrange
      when(() => catalogItemRepository.getAllCatalogItems()).thenAnswer(
        (_) async => const Success<Map<String, List<CatalogItemEntity>>>({}),
      );

      when(() => favoriteRepository.getFavorites(userId))
          .thenAnswer((_) async => const Success<List<FavoriteEntity>>([]));

      // Act
      final result = await useCase.call(userId);

      // Assert
      expect(
        result,
        isA<Success<Map<String, List<CatalogItemWithFavorite>>>>(),
      );

      final data =
          (result as Success<Map<String, List<CatalogItemWithFavorite>>>).data;

      expect(data, isEmpty);
    });
  });
}
