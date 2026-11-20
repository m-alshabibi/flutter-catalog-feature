import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/error/failures.dart';
import 'package:flutter_catalog_feature/core/result/result.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/catalog_item_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/add_favorite_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/get_favorite_catalog_items_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/params/add_favorite_params.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/refresh_favorites_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/remove_favorite_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/favorites/favorites_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockGetFavoriteCatalogItemsUseCase extends Mock
    implements GetFavoriteCatalogItemsUseCase {}

class MockAddFavoriteUseCase extends Mock implements AddFavoriteUseCase {}

class MockRemoveFavoriteUseCase extends Mock implements RemoveFavoriteUseCase {}

class MockRefreshFavoritesUseCase extends Mock
    implements RefreshFavoritesUseCase {}

void main() {
  late FavoritesCubit cubit;

  late MockGetFavoriteCatalogItemsUseCase mockGetFavoriteCatalogItemsUseCase;
  late MockAddFavoriteUseCase mockAddFavoriteUseCase;
  late MockRemoveFavoriteUseCase mockRemoveFavoriteUseCase;
  late MockRefreshFavoritesUseCase mockRefreshFavoritesUseCase;

  const userId = 'user-1';

  final item = CatalogItemEntity(
    id: 'item-1',
    groupId: 'group-1',
    name: 'Item 1',
  );

  final secondItem = CatalogItemEntity(
    id: 'item-2',
    groupId: 'group-1',
    name: 'Item 2',
  );

  setUpAll(() {
    registerFallbackValue(AddFavoriteParams(userId: '', catalogItemId: ''));
  });

  setUp(() {
    mockGetFavoriteCatalogItemsUseCase = MockGetFavoriteCatalogItemsUseCase();
    mockAddFavoriteUseCase = MockAddFavoriteUseCase();
    mockRemoveFavoriteUseCase = MockRemoveFavoriteUseCase();
    mockRefreshFavoritesUseCase = MockRefreshFavoritesUseCase();

    cubit = FavoritesCubit(
      userId: userId,
      getFavoriteCatalogItemsUseCase: mockGetFavoriteCatalogItemsUseCase,
      addFavoriteUseCase: mockAddFavoriteUseCase,
      removeFavoriteUseCase: mockRemoveFavoriteUseCase,
      refreshFavoritesUseCase: mockRefreshFavoritesUseCase,
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  group('FavoritesCubit', () {
    test('initial state should be empty', () {
      expect(cubit.state.favoriteItems, isEmpty);
      expect(cubit.state.favoriteItemIds, isEmpty);
      expect(cubit.state.hasLoaded, isFalse);
    });

    group('loadFavorites', () {
      test('should load local favorites then refresh remote data', () async {
        var callCount = 0;

        when(() => mockGetFavoriteCatalogItemsUseCase(userId))
            .thenAnswer((_) async {
              callCount++;

              return Success<List<CatalogItemEntity>>(
                callCount == 1 ? [item] : [item, secondItem],
              );
            });

        when(() => mockRefreshFavoritesUseCase(userId))
            .thenAnswer((_) async => Success<void>(null));

        await cubit.loadFavorites();

        expect(cubit.state.favoriteItems, [item, secondItem]);
        expect(cubit.state.favoriteItemIds, {'item-1', 'item-2'});
        expect(cubit.state.hasLoaded, isTrue);
        expect(cubit.state.isLoading, isFalse);
        expect(cubit.state.isRefreshing, isFalse);

        verify(() => mockGetFavoriteCatalogItemsUseCase(userId)).called(2);

        verify(() => mockRefreshFavoritesUseCase(userId)).called(1);
      });

      test('should preserve local data when remote refresh fails', () async {
        when(() => mockGetFavoriteCatalogItemsUseCase(userId))
            .thenAnswer((_) async => Success<List<CatalogItemEntity>>([item]));

        when(
          () => mockRefreshFavoritesUseCase(userId),
        ).thenAnswer((_) async => FailureResult<void>(const UnknownFailure()));

        await cubit.loadFavorites();

        expect(cubit.state.favoriteItems, [item]);
        expect(cubit.state.favoriteItemIds, {'item-1'});
        expect(cubit.state.hasLoaded, isTrue);
        expect(cubit.state.isLoading, isFalse);
        expect(cubit.state.isRefreshing, isFalse);
      });

      test('should not load favorites more than once', () async {
        when(() => mockGetFavoriteCatalogItemsUseCase(userId))
            .thenAnswer((_) async => Success<List<CatalogItemEntity>>([item]));

        when(() => mockRefreshFavoritesUseCase(userId))
            .thenAnswer((_) async => Success<void>(null));

        await cubit.loadFavorites();
        await cubit.loadFavorites();

        verify(() => mockGetFavoriteCatalogItemsUseCase(userId)).called(2);
      });
    });

    group('addFavorite', () {
      setUp(() async {
        when(() => mockGetFavoriteCatalogItemsUseCase(userId))
            .thenAnswer((_) async => Success<List<CatalogItemEntity>>([]));

        when(() => mockRefreshFavoritesUseCase(userId))
            .thenAnswer((_) async => Success<void>(null));

        await cubit.loadFavorites();
      });

      test('should add item and reload favorite items', () async {
        when(() => mockAddFavoriteUseCase(any()))
            .thenAnswer((_) async => Success<void>(null));

        when(() => mockGetFavoriteCatalogItemsUseCase(userId))
            .thenAnswer((_) async => Success<List<CatalogItemEntity>>([item]));

        await cubit.addFavorite('item-1');

        expect(cubit.state.isFavorite('item-1'), isTrue);
        expect(cubit.state.favoriteItems, [item]);
        expect(cubit.state.isUpdating('item-1'), isFalse);

        verify(
          () => mockAddFavoriteUseCase(
            any(
              that: isA<AddFavoriteParams>()
                  .having((p) => p.userId, 'userId', userId)
                  .having((p) => p.catalogItemId, 'catalogItemId', 'item-1'),
            ),
          ),
        ).called(1);
      });

      test('should ignore adding an already favorite item', () async {
        when(() => mockAddFavoriteUseCase(any()))
            .thenAnswer((_) async => Success<void>(null));

        // Establish an existing favorite.
        when(() => mockGetFavoriteCatalogItemsUseCase(userId))
            .thenAnswer((_) async => Success<List<CatalogItemEntity>>([item]));

        await cubit.refreshFavorites();

        await cubit.addFavorite('item-1');

        verifyNever(() => mockAddFavoriteUseCase(any()));
      });
    });

    group('removeFavorite', () {
      setUp(() async {
        when(() => mockGetFavoriteCatalogItemsUseCase(userId))
            .thenAnswer((_) async => Success<List<CatalogItemEntity>>([item]));

        when(() => mockRefreshFavoritesUseCase(userId))
            .thenAnswer((_) async => Success<void>(null));

        await cubit.loadFavorites();
      });

      test('should remove item from IDs and favorite items', () async {
        when(() => mockRemoveFavoriteUseCase(any()))
            .thenAnswer((_) async => Success<void>(null));

        await cubit.removeFavorite('item-1');

        expect(cubit.state.favoriteItems, isEmpty);
        expect(cubit.state.favoriteItemIds, isEmpty);
        expect(cubit.state.isFavorite('item-1'), isFalse);
        expect(cubit.state.isUpdating('item-1'), isFalse);

        verify(
          () => mockRemoveFavoriteUseCase(
            any(
              that: isA<AddFavoriteParams>()
                  .having((p) => p.userId, 'userId', userId)
                  .having((p) => p.catalogItemId, 'catalogItemId', 'item-1'),
            ),
          ),
        ).called(1);
      });

      test('should ignore removing a non-favorite item', () async {
        when(() => mockRemoveFavoriteUseCase(any()))
            .thenAnswer((_) async => Success<void>(null));

        await cubit.removeFavorite('item-2');

        verifyNever(() => mockRemoveFavoriteUseCase(any()));
      });
    });

    group('toggleFavorite', () {
      test('should add item when it is not favorite', () async {
        when(() => mockGetFavoriteCatalogItemsUseCase(userId))
            .thenAnswer((_) async => Success<List<CatalogItemEntity>>([]));

        when(() => mockRefreshFavoritesUseCase(userId))
            .thenAnswer((_) async => Success<void>(null));

        when(() => mockAddFavoriteUseCase(any()))
            .thenAnswer((_) async => Success<void>(null));

        await cubit.loadFavorites();

        when(() => mockGetFavoriteCatalogItemsUseCase(userId))
            .thenAnswer((_) async => Success<List<CatalogItemEntity>>([item]));

        await cubit.toggleFavorite('item-1');

        expect(cubit.state.isFavorite('item-1'), isTrue);

        verify(() => mockAddFavoriteUseCase(any())).called(1);
      });
    });

    group('refreshFavorites', () {
      test('should refresh and update favorite items', () async {
        when(() => mockGetFavoriteCatalogItemsUseCase(userId))
            .thenAnswer((_) async => Success<List<CatalogItemEntity>>([item]));

        when(() => mockRefreshFavoritesUseCase(userId))
            .thenAnswer((_) async => Success<void>(null));

        await cubit.refreshFavorites();

        expect(cubit.state.favoriteItems, [item]);
        expect(cubit.state.favoriteItemIds, {'item-1'});
        expect(cubit.state.isRefreshing, isFalse);
      });

      test('should preserve cached data when refresh fails', () async {
        when(() => mockGetFavoriteCatalogItemsUseCase(userId))
            .thenAnswer((_) async => Success<List<CatalogItemEntity>>([item]));

        when(() => mockRefreshFavoritesUseCase(userId))
            .thenAnswer((_) async => Success<void>(null));

        await cubit.loadFavorites();

        when(
          () => mockRefreshFavoritesUseCase(userId),
        ).thenAnswer((_) async => FailureResult<void>(const UnknownFailure()));

        await cubit.refreshFavorites();

        expect(cubit.state.favoriteItems, [item]);
        expect(cubit.state.favoriteItemIds, {'item-1'});
        expect(cubit.state.isRefreshing, isFalse);
      });
    });
  });
}
