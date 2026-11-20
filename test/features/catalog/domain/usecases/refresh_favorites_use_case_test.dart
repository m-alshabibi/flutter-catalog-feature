import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/error/failures.dart';
import 'package:flutter_catalog_feature/core/result/result.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/repositories/favorite_repository.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/refresh_favorites_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockFavoriteRepository extends Mock implements FavoriteRepository {}

void main() {
  late MockFavoriteRepository repository;
  late RefreshFavoritesUseCase useCase;

  const userId = 'user-1';

  setUp(() {
    repository = MockFavoriteRepository();
    useCase = RefreshFavoritesUseCase(repository);
  });

  group('RefreshFavoritesUseCase', () {
    test('should refresh favorites successfully', () async {
      // Arrange
      when(() => repository.refreshFavorites(userId))
          .thenAnswer((_) async => const Success<void>(null));

      // Act
      final result = await useCase.call(userId);

      // Assert
      expect(result, isA<Success<void>>());

      verify(() => repository.refreshFavorites(userId)).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('should return failure when refreshing favorites fails', () async {
      // Arrange
      const failure = NetworkFailure();

      when(() => repository.refreshFavorites(userId))
          .thenAnswer((_) async => const FailureResult<void>(failure));

      // Act
      final result = await useCase.call(userId);

      // Assert
      expect(result, isA<FailureResult<void>>());

      final resultFailure = (result as FailureResult<void>).failure;
      expect(resultFailure, isA<NetworkFailure>());

      verify(() => repository.refreshFavorites(userId)).called(1);
      verifyNoMoreInteractions(repository);
    });
  });
}
