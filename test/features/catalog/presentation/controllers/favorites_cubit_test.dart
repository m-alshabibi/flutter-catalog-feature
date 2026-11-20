import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/result/result.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/favorite_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/add_favorite_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/get_favorite_catalog_items_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/refresh_favorites_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/remove_favorite_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/favorites/favorites_cubit.dart';
import '../../../../support/fake_repositories.dart';
import '../../../../support/fixtures.dart';

class UpdatingFavoriteRepository extends FakeFavoriteRepository {
  @override
  Future<Result<void>> addFavorite(String userId, String catalogItemId) async {
    final current = (favoritesResult as Success<List<FavoriteEntity>>).data;
    lastUserId = userId;
    lastCatalogItemId = catalogItemId;
    favoritesResult = Success([...current, makeFavorite(catalogItemId: catalogItemId)]);
    return const Success(null);
  }
}

void main() {
  late UpdatingFavoriteRepository favorites;
  late FakeCatalogItemRepository items;
  late FavoritesCubit cubit;

  setUp(() {
    favorites = UpdatingFavoriteRepository()
      ..favoritesResult = Success([makeFavorite()]);
    items = FakeCatalogItemRepository()..itemsByIdsResult = Success([makeItem()]);
    cubit = FavoritesCubit(
      userId: 'user-1',
      getFavoriteCatalogItemsUseCase: GetFavoriteCatalogItemsUseCase(
        favoriteRepository: favorites,
        catalogItemRepository: items,
      ),
      addFavoriteUseCase: AddFavoriteUseCase(favorites),
      removeFavoriteUseCase: RemoveFavoriteUseCase(favorites),
      refreshFavoritesUseCase: RefreshFavoritesUseCase(favorites),
    );
  });

  tearDown(() async => cubit.close());

  test('loads favorite items and their IDs', () async {
    await cubit.loadFavorites();
    expect(cubit.state.favoriteItems.single.id, 'item-1');
    expect(cubit.state.isFavorite('item-1'), isTrue);
    expect(cubit.state.hasLoaded, isTrue);
    expect(favorites.refreshCalls, 1);
  });

  test('adds a favorite and refreshes the displayed item list', () async {
    favorites.favoritesResult = const Success<List<FavoriteEntity>>([]);
    items.itemsByIdsResult = Success([makeItem(id: 'item-2')]);
    await cubit.addFavorite('item-2');
    expect(cubit.state.isFavorite('item-2'), isTrue);
    expect(cubit.state.isUpdating('item-2'), isFalse);
    expect(favorites.lastCatalogItemId, 'item-2');
  });

  test('removes a favorite from state', () async {
    await cubit.loadFavorites();
    await cubit.removeFavorite('item-1');
    expect(cubit.state.isFavorite('item-1'), isFalse);
    expect(cubit.state.favoriteItems, isEmpty);
    expect(favorites.removeCalls, 1);
  });
}
