import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/domain/usecases/no_params.dart';
import 'package:flutter_catalog_feature/core/error/failures.dart';
import 'package:flutter_catalog_feature/core/result/result.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/catalog_item_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/repositories/catalog_item_repository.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/get_all_catalog_items_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockCatalogItemRepository extends Mock implements CatalogItemRepository {}

void main() {
  late MockCatalogItemRepository repository;
  late GetAllCatalogItemsUseCase useCase;

  setUp(() {
    repository = MockCatalogItemRepository();
    useCase = GetAllCatalogItemsUseCase(repository);
  });

  group('GetAllCatalogItemsUseCase', () {
    test('should return all catalog items grouped by group ID', () async {
      // Arrange
      final items = <String, List<CatalogItemEntity>>{
        'group-1': [],
        'group-2': [],
      };

      when(() => repository.getAllCatalogItems())
          .thenAnswer((_) async => Success(items));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result, isA<Success<Map<String, List<CatalogItemEntity>>>>());

      final data =
          (result as Success<Map<String, List<CatalogItemEntity>>>).data;

      expect(data, equals(items));
      expect(data.keys, containsAll(['group-1', 'group-2']));

      verify(() => repository.getAllCatalogItems()).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = NetworkFailure();

      when(() => repository.getAllCatalogItems())
          .thenAnswer((_) async => const FailureResult(failure));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(
        result,
        isA<FailureResult<Map<String, List<CatalogItemEntity>>>>(),
      );

      final actualFailure =
          (result as FailureResult<Map<String, List<CatalogItemEntity>>>)
              .failure;

      expect(actualFailure, isA<NetworkFailure>());

      verify(() => repository.getAllCatalogItems()).called(1);
    });
  });
}
