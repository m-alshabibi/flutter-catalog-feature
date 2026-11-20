import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/error/failures.dart';
import 'package:flutter_catalog_feature/core/result/result.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/catalog_item_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/repositories/catalog_item_repository.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/get_catalog_items_by_ids_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockCatalogItemRepository extends Mock implements CatalogItemRepository {}

void main() {
  late MockCatalogItemRepository repository;
  late GetCatalogItemsByIdsUseCase useCase;

  setUp(() {
    repository = MockCatalogItemRepository();
    useCase = GetCatalogItemsByIdsUseCase(repository);
  });

  group('GetCatalogItemsByIdsUseCase', () {
    final ids = {'item-1', 'item-2'};

    test('should return catalog items matching requested IDs', () async {
      // Arrange
      final items = <CatalogItemEntity>[];

      when(() => repository.getCatalogItemsByIds(ids))
          .thenAnswer((_) async => Success(items));

      // Act
      final result = await useCase(ids);

      // Assert
      expect(result, isA<Success<List<CatalogItemEntity>>>());
      expect((result as Success<List<CatalogItemEntity>>).data, equals(items));

      verify(() => repository.getCatalogItemsByIds(ids)).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = CacheFailure();

      when(() => repository.getCatalogItemsByIds(ids))
          .thenAnswer((_) async => const FailureResult(failure));

      // Act
      final result = await useCase(ids);

      // Assert
      expect(result, isA<FailureResult<List<CatalogItemEntity>>>());
      expect(
        (result as FailureResult<List<CatalogItemEntity>>).failure,
        isA<CacheFailure>(),
      );

      verify(() => repository.getCatalogItemsByIds(ids)).called(1);
    });

    test('should pass an empty set to the repository', () async {
      // Arrange
      when(() => repository.getCatalogItemsByIds(<String>{}))
          .thenAnswer((_) async => Success(<CatalogItemEntity>[]));

      // Act
      final result = await useCase(<String>{});

      // Assert
      expect(result, isA<Success<List<CatalogItemEntity>>>());
      verify(() => repository.getCatalogItemsByIds(<String>{})).called(1);
    });
  });
}
