import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/error/failures.dart';
import 'package:flutter_catalog_feature/core/result/result.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/favorite_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/repositories/favorite_repository.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/get_favorites_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockFavoriteRepository extends Mock implements FavoriteRepository {}

void main() {
  late MockFavoriteRepository repository;
  late GetFavoritesUseCase useCase;

  setUp(() {
    repository = MockFavoriteRepository();
    useCase = GetFavoritesUseCase(repository);
  });

  group('GetFavoritesUseCase', () {
    const userId = 'user-1';

    test('should return favorites for the requested user', () async {
      // Arrange
      final favorites = <FavoriteEntity>[];

      when(() => repository.getFavorites(userId))
          .thenAnswer((_) async => Success(favorites));

      // Act
      final result = await useCase(userId);

      // Assert
      expect(result, isA<Success<List<FavoriteEntity>>>());
      expect((result as Success<List<FavoriteEntity>>).data, equals(favorites));

      verify(() => repository.getFavorites(userId)).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = CacheFailure();

      when(() => repository.getFavorites(userId))
          .thenAnswer((_) async => const FailureResult(failure));

      // Act
      final result = await useCase(userId);

      // Assert
      expect(result, isA<FailureResult<List<FavoriteEntity>>>());
      expect(
        (result as FailureResult<List<FavoriteEntity>>).failure,
        isA<CacheFailure>(),
      );

      verify(() => repository.getFavorites(userId)).called(1);
    });
  });
}
