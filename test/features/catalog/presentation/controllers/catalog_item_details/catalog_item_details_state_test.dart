import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/error/failures.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/catalog_item_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/catalog_item_details/catalog_item_details_state.dart';

void main() {
  late CatalogItemEntity item;

  setUp(() {
    item = CatalogItemEntity(
      id: 'item-1',
      groupId: 'group-1',
      name: 'Service 1',
    );
  });

  group('CatalogItemDetailsState', () {
    test('should use default values', () {
      const state = CatalogItemDetailsState();

      expect(state.item, isNull);
      expect(state.hasLoaded, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.isRefreshing, isFalse);
      expect(state.failure, isNull);
    });

    test('copyWith should update item and inherited properties', () {
      final state = const CatalogItemDetailsState().copyWith(
        item: item,
        hasLoaded: true,
        isLoading: true,
      );

      expect(state.item, item);
      expect(state.hasLoaded, isTrue);
      expect(state.isLoading, isTrue);
    });

    test('copyWith should preserve existing values', () {
      final original = CatalogItemDetailsState(item: item, hasLoaded: true);

      final updated = original.copyWith(isLoading: true);

      expect(updated.item, item);
      expect(updated.hasLoaded, isTrue);
      expect(updated.isLoading, isTrue);
    });

    test('copyWith should clear item and failure', () {
      final original = CatalogItemDetailsState(
        item: item,
        failure: const UnknownFailure(),
      );

      final updated = original.copyWith(clearItem: true, clearFailure: true);

      expect(updated.item, isNull);
      expect(updated.failure, isNull);
    });
  });
}
