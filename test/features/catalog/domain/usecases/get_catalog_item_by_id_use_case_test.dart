import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/error/failures.dart';
import 'package:flutter_catalog_feature/core/result/result.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/catalog_item_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/repositories/catalog_item_repository.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/get_catalog_item_by_id_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockCatalogItemRepository extends Mock implements CatalogItemRepository {}

void main() {
  late MockCatalogItemRepository repository;
  late GetCatalogItemByIdUseCase useCase;

  setUp(() {
    repository = MockCatalogItemRepository();
    useCase = GetCatalogItemByIdUseCase(repository);
  });

  group('GetCatalogItemByIdUseCase', () {
    const itemId = 'item-1';

    test('should return the requested catalog item', () async {
      // Arrange
      final item = CatalogItemEntity(
        id: itemId,
        groupId: 'group-1',
        name: 'Test Item',
      );

      when(() => repository.getCatalogItemById(itemId))
          .thenAnswer((_) async => Success(item));

      // Act
      final result = await useCase(itemId);

      // Assert
      expect(result, isA<Success<CatalogItemEntity>>());
      expect((result as Success<CatalogItemEntity>).data, equals(item));

      verify(() => repository.getCatalogItemById(itemId)).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = NotFoundFailure();

      when(() => repository.getCatalogItemById(itemId))
          .thenAnswer((_) async => const FailureResult(failure));

      // Act
      final result = await useCase(itemId);

      // Assert
      expect(result, isA<FailureResult<CatalogItemEntity>>());
      expect(
        (result as FailureResult<CatalogItemEntity>).failure,
        isA<NotFoundFailure>(),
      );

      verify(() => repository.getCatalogItemById(itemId)).called(1);
    });
  });
}
