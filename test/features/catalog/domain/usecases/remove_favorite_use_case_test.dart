import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/error/failures.dart';
import 'package:flutter_catalog_feature/core/result/result.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/repositories/favorite_repository.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/params/add_favorite_params.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/remove_favorite_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockFavoriteRepository extends Mock implements FavoriteRepository {}

void main() {
  late MockFavoriteRepository repository;
  late RemoveFavoriteUseCase useCase;

  setUp(() {
    repository = MockFavoriteRepository();
    useCase = RemoveFavoriteUseCase(repository);
  });

  group('RemoveFavoriteUseCase', () {
    const params = AddFavoriteParams(userId: 'user-1', catalogItemId: 'item-1');

    test('should remove the requested catalog item from favorites', () async {
      // Arrange
      when(() => repository.removeFavorite(params.userId, params.catalogItemId))
          .thenAnswer((_) async => const Success<void>(null));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, isA<Success<void>>());

      verify(
        () => repository.removeFavorite(params.userId, params.catalogItemId),
      ).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = CacheFailure();

      when(() => repository.removeFavorite(params.userId, params.catalogItemId))
          .thenAnswer((_) async => const FailureResult<void>(failure));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, isA<FailureResult<void>>());

      final actualFailure = (result as FailureResult<void>).failure;
      expect(actualFailure, isA<CacheFailure>());

      verify(
        () => repository.removeFavorite(params.userId, params.catalogItemId),
      ).called(1);
    });
  });
}
