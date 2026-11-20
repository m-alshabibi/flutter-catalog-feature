import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/error/failures.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/catalog_item_details/catalog_item_details_state.dart';
import '../../../../support/fixtures.dart';

void main() {
  test('holds and clears its catalog item', () {
    final item = makeItem();
    final state = CatalogItemDetailsState(item: item, hasLoaded: true);
    expect(state.copyWith().item, same(item));
    expect(state.copyWith(clearItem: true).item, isNull);
  });

  test('clears failure explicitly', () {
    final state = CatalogItemDetailsState(failure: const NetworkFailure('offline'));
    expect(state.copyWith(clearFailure: true).failure, isNull);
  });
}
