import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/error/failures.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/catalog/catalog_state.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/catalog/group_catalog_state.dart';
import '../../../../support/fixtures.dart';

void main() {
  test('CatalogState protects collections and returns a default group state', () {
    final groups = [makeGroup()];
    final map = <String, GroupCatalogState>{};
    final state = CatalogState(groups: groups, catalogByGroupId: map);
    groups.clear();
    map['g1'] = GroupCatalogState();

    expect(state.groups, hasLength(1));
    expect(state.catalogByGroupId, isEmpty);
    expect(state.groupState('not-loaded').hasLoaded, isFalse);
    expect(() => state.groups.add(makeGroup(id: 'g2')), throwsUnsupportedError);
  });

  test('CatalogState copyWith preserves and clears failures', () {
    const failure = NetworkFailure('offline');
    final state = CatalogState(failure: failure, hasLoaded: true);
    expect(state.copyWith().failure, same(failure));
    expect(state.copyWith(clearFailure: true).failure, isNull);
  });

  test('GroupCatalogState protects items and copies load flags', () {
    final items = [makeItem()];
    final state = GroupCatalogState(items: items, hasLoaded: true);
    items.clear();
    expect(state.items, hasLength(1));
    expect(state.copyWith(isRefreshing: true).isRefreshing, isTrue);
    expect(() => state.items.clear(), throwsUnsupportedError);
  });
}
