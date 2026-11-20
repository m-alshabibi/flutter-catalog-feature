import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/catalog_item_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/favorites/favorites_state.dart';

void main() {
  late CatalogItemEntity item;
  late FavoritesState state;

  setUp(() {
    item = CatalogItemEntity(id: 'item-1', groupId: 'group-1', name: 'Item 1');

    state = FavoritesState(
      favoriteItems: [item],
      favoriteItemIds: {'item-1'},
      updatingItemIds: {'item-2'},
      hasLoaded: true,
    );
  });

  group('FavoritesState', () {
    test('should initialize with default values', () {
      final state = FavoritesState();

      expect(state.favoriteItems, isEmpty);
      expect(state.favoriteItemIds, isEmpty);
      expect(state.updatingItemIds, isEmpty);
      expect(state.hasLoaded, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.isRefreshing, isFalse);
      expect(state.failure, isNull);
    });

    test('should check whether an item is favorite', () {
      expect(state.isFavorite('item-1'), isTrue);
      expect(state.isFavorite('item-2'), isFalse);
    });

    test('should check whether an item is updating', () {
      expect(state.isUpdating('item-2'), isTrue);
      expect(state.isUpdating('item-1'), isFalse);
    });

    test('should make collections unmodifiable', () {
      expect(() => state.favoriteItems.add(item), throwsUnsupportedError);

      expect(() => state.favoriteItemIds.add('item-3'), throwsUnsupportedError);

      expect(() => state.updatingItemIds.add('item-3'), throwsUnsupportedError);
    });

    test('copyWith should preserve unchanged values', () {
      final updatedState = state.copyWith(isRefreshing: true);

      expect(updatedState.favoriteItems, [item]);
      expect(updatedState.favoriteItemIds, {'item-1'});
      expect(updatedState.updatingItemIds, {'item-2'});
      expect(updatedState.hasLoaded, isTrue);
      expect(updatedState.isRefreshing, isTrue);
    });

    test('copyWith should update favorite items and IDs', () {
      final updatedState = state.copyWith(
        favoriteItems: [],
        favoriteItemIds: {},
      );

      expect(updatedState.favoriteItems, isEmpty);
      expect(updatedState.favoriteItemIds, isEmpty);
    });
  });
}
