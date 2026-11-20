import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/error/failures.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/favorites/favorites_state.dart';
import '../../../../support/fixtures.dart';

void main() {
  test('FavoritesState copies immutable items and ID sets', () {
    final items = [makeItem()];
    final ids = {'item-1'};
    final updating = {'item-2'};
    final state = FavoritesState(
      favoriteItems: items,
      favoriteItemIds: ids,
      updatingItemIds: updating,
    );
    items.clear();
    ids.add('item-3');
    updating.clear();

    expect(state.favoriteItems, hasLength(1));
    expect(state.favoriteItemIds, {'item-1'});
    expect(state.updatingItemIds, {'item-2'});
    expect(state.isFavorite('item-1'), isTrue);
    expect(state.isUpdating('item-2'), isTrue);
    expect(() => state.favoriteItemIds.add('x'), throwsUnsupportedError);
  });

  test('copyWith clears failures and keeps unspecified values', () {
    final state = FavoritesState(failure: const NetworkFailure('offline'));
    expect(state.copyWith().failure, isNotNull);
    expect(state.copyWith(clearFailure: true).failure, isNull);
  });
}

