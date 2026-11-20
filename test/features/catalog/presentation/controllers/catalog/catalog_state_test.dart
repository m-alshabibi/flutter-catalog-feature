import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/error/failures.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/catalog/catalog_state.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/catalog/group_catalog_state.dart';

void main() {
  group('GroupCatalogState', () {
    test('should use default values', () {
      final state = GroupCatalogState();

      expect(state.items, isEmpty);
      expect(state.isLoading, false);
      expect(state.isRefreshing, false);
      expect(state.failure, isNull);
    });

    test('should preserve existing values when using copyWith', () {
      final state = GroupCatalogState(isLoading: true);

      final updated = state.copyWith(isRefreshing: true);

      expect(updated.isLoading, true);
      expect(updated.isRefreshing, true);
    });

    test('should clear failure when requested', () {
      final state = GroupCatalogState(
        failure: const UnknownFailure('Loading failed'),
      );

      final updated = state.copyWith(clearFailure: true);

      expect(updated.failure, isNull);
    });

    test('should prevent modifying items', () {
      final state = GroupCatalogState();

      expect(
        () => state.items.add(throw UnimplementedError()),
        throwsUnsupportedError,
      );
    });
  });

  group('CatalogState', () {
    test('should use default values', () {
      final state = CatalogState();

      expect(state.groups, isEmpty);
      expect(state.catalogByGroupId, isEmpty);
      expect(state.isLoading, false);
      expect(state.isRefreshing, false);
      expect(state.failure, isNull);
    });

    test('should preserve values when using copyWith', () {
      final state = CatalogState(isLoading: true);

      final updated = state.copyWith(isRefreshing: true);

      expect(updated.isLoading, true);
      expect(updated.isRefreshing, true);
    });

    test('should clear groups failure when requested', () {
      final state = CatalogState(
        failure: const UnknownFailure('Groups failed'),
      );

      final updated = state.copyWith(clearFailure: true);

      expect(updated.failure, isNull);
    });

    test('should return empty state for an unloaded group', () {
      final state = CatalogState();

      final groupState = state.groupState('group-1');

      expect(groupState.items, isEmpty);
      expect(groupState.isLoading, false);
    });

    test('should preserve unchanged group state references', () {
      final groupState = GroupCatalogState();

      final state = CatalogState(catalogByGroupId: {'group-1': groupState});

      final updated = state.copyWith(isRefreshing: true);

      expect(
        identical(
          state.catalogByGroupId['group-1'],
          updated.catalogByGroupId['group-1'],
        ),
        true,
      );
    });

    test('should prevent modifying catalog map', () {
      final state = CatalogState();

      expect(
        () => state.catalogByGroupId['group-1'] = GroupCatalogState(),
        throwsUnsupportedError,
      );
    });
  });
}
