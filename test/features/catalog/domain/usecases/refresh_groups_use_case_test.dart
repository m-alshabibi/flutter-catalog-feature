import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/domain/usecases/no_params.dart';
import 'package:flutter_catalog_feature/core/error/failures.dart';
import 'package:flutter_catalog_feature/core/result/result.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/repositories/group_repository.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/refresh_groups_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

void main() {
  late MockGroupRepository repository;
  late RefreshGroupsUseCase useCase;

  setUp(() {
    repository = MockGroupRepository();
    useCase = RefreshGroupsUseCase(repository);
  });

  group('RefreshGroupsUseCase', () {
    test('should refresh groups successfully', () async {
      // Arrange
      when(() => repository.refreshGroups())
          .thenAnswer((_) async => const Success<void>(null));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result, isA<Success<void>>());
      verify(() => repository.refreshGroups()).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = NetworkFailure();

      when(() => repository.refreshGroups())
          .thenAnswer((_) async => const FailureResult<void>(failure));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result, isA<FailureResult<void>>());

      final actualFailure = (result as FailureResult<void>).failure;
      expect(actualFailure, isA<NetworkFailure>());

      verify(() => repository.refreshGroups()).called(1);
    });
  });
}
