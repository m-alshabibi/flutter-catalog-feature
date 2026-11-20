import 'package:flutter_catalog_feature/core/domain/models/pagination_params.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/catalog_item_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/group_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/models/catalog_item_with_favorite.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/models/group_with_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final group = GroupEntity(id: 'g1', name: 'Group');
  final item = CatalogItemEntity(id: 'i1', groupId: 'g1', name: 'Item');

  test('GroupWithCatalog protects its item list', () {
    final source = [item];
    final model = GroupWithCatalog(group: group, catalogItems: source);
    source.clear();
    expect(model.catalogItems, hasLength(1));
    expect(() => model.catalogItems.add(item), throwsUnsupportedError);
  });

  test('CatalogItemWithFavorite stores item and favorite flag', () {
    final model = CatalogItemWithFavorite(catalogItem: item, isFavorite: true);
    expect(model.catalogItem, item);
    expect(model.isFavorite, isTrue);
  });

  test('PaginationParams applies its defaults and validates values', () {
    final params = PaginationParams();
    expect(params.limit, PaginationParams.defaultPageSize);
    expect(params.offset, 0);
    expect(params.nextPage().offset, params.limit);
    expect(() => PaginationParams(limit: 0), throwsAssertionError);
    expect(() => PaginationParams(offset: -1), throwsAssertionError);
  });
}
