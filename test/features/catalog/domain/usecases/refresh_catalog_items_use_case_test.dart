import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/domain/usecases/no_params.dart';
import 'package:flutter_catalog_feature/core/error/failures.dart';
import 'package:flutter_catalog_feature/core/result/result.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/repositories/catalog_item_repository.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/refresh_catalog_items_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockCatalogItemRepository extends Mock implements CatalogItemRepository {}

void main() {
  late MockCatalogItemRepository repository;
  late RefreshCatalogItemsUseCase useCase;

  setUp(() {
    repository = MockCatalogItemRepository();
    useCase = RefreshCatalogItemsUseCase(repository);
  });

  group('RefreshCatalogItemsUseCase', () {
    test('should refresh all catalog items successfully', () async {
      // Arrange
      when(() => repository.refreshCatalogItems())
          .thenAnswer((_) async => const Success<void>(null));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result, isA<Success<void>>());

      verify(() => repository.refreshCatalogItems()).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = NetworkFailure();

      when(() => repository.refreshCatalogItems())
          .thenAnswer((_) async => const FailureResult<void>(failure));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result, isA<FailureResult<void>>());

      final actualFailure = (result as FailureResult<void>).failure;
      expect(actualFailure, isA<NetworkFailure>());

      verify(() => repository.refreshCatalogItems()).called(1);
    });
  });
}
