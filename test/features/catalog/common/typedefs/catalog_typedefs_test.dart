import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/features/catalog/common/typedefs/catalog_types.dart';
import 'package:flutter_catalog_feature/features/catalog/common/typedefs/favorite_types.dart';
import 'package:flutter_catalog_feature/features/catalog/common/typedefs/group_types.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/models/catalog_item_with_favorite.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/models/group_with_catalog.dart';
import '../../../../support/fixtures.dart';

void main() {
  test('feature typedefs represent their documented collections', () {
    final Groups groups = [makeGroup()];
    final Favorites favorites = [makeFavorite()];
    final CatalogItemsByGroup catalog = {'group-1': [makeItem()]};
    final CatalogItemsWithFavorite flags = [
      CatalogItemWithFavorite(catalogItem: makeItem(), isFavorite: true),
    ];
    final CatalogItemsWithFavoriteByGroup groupedFlags = {'group-1': flags};
    final GroupsWithCatalog groupsWithItems = [
      GroupWithCatalog(group: makeGroup(), catalogItems: [makeItem()]),
    ];

    expect(groups, hasLength(1));
    expect(favorites, hasLength(1));
    expect(catalog['group-1'], hasLength(1));
    expect(groupedFlags['group-1']!.single.isFavorite, isTrue);
    expect(groupsWithItems.single.catalogItems, hasLength(1));
  });
}
