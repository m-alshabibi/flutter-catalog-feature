import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/error/failures.dart';
import 'package:flutter_catalog_feature/core/result/result.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/catalog_item_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/repositories/catalog_item_repository.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/get_catalog_items_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockCatalogItemRepository extends Mock implements CatalogItemRepository {}

void main() {
  late MockCatalogItemRepository repository;
  late GetCatalogItemsUseCase useCase;

  setUp(() {
    repository = MockCatalogItemRepository();
    useCase = GetCatalogItemsUseCase(repository);
  });

  group('GetCatalogItemsUseCase', () {
    const groupId = 'group-1';

    test('should return catalog items for the requested group', () async {
      // Arrange
      final items = <CatalogItemEntity>[];

      when(() => repository.getCatalogItems(groupId))
          .thenAnswer((_) async => Success(items));

      // Act
      final result = await useCase(groupId);

      // Assert
      expect(result, isA<Success<List<CatalogItemEntity>>>());
      expect((result as Success<List<CatalogItemEntity>>).data, equals(items));

      verify(() => repository.getCatalogItems(groupId)).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = NetworkFailure();

      when(() => repository.getCatalogItems(groupId))
          .thenAnswer((_) async => const FailureResult(failure));

      // Act
      final result = await useCase(groupId);

      // Assert
      expect(result, isA<FailureResult<List<CatalogItemEntity>>>());
      expect(
        (result as FailureResult<List<CatalogItemEntity>>).failure,
        isA<NetworkFailure>(),
      );

      verify(() => repository.getCatalogItems(groupId)).called(1);
    });
  });
}
