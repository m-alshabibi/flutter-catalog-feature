import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/error/failures.dart';
import 'package:flutter_catalog_feature/core/result/result.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/repositories/catalog_item_repository.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/refresh_catalog_items_by_group_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockCatalogItemRepository extends Mock implements CatalogItemRepository {}

void main() {
  late MockCatalogItemRepository repository;
  late RefreshCatalogItemsByGroupUseCase useCase;

  setUp(() {
    repository = MockCatalogItemRepository();
    useCase = RefreshCatalogItemsByGroupUseCase(repository);
  });

  group('RefreshCatalogItemsByGroupUseCase', () {
    const groupId = 'group-1';

    test('should refresh catalog items for the requested group', () async {
      // Arrange
      when(() => repository.refreshCatalogItemsByGroup(groupId))
          .thenAnswer((_) async => const Success<void>(null));

      // Act
      final result = await useCase(groupId);

      // Assert
      expect(result, isA<Success<void>>());

      verify(() => repository.refreshCatalogItemsByGroup(groupId)).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = NetworkFailure();

      when(() => repository.refreshCatalogItemsByGroup(groupId))
          .thenAnswer((_) async => const FailureResult<void>(failure));

      // Act
      final result = await useCase(groupId);

      // Assert
      expect(result, isA<FailureResult<void>>());

      final actualFailure = (result as FailureResult<void>).failure;
      expect(actualFailure, isA<NetworkFailure>());

      verify(() => repository.refreshCatalogItemsByGroup(groupId)).called(1);
    });
  });
}
