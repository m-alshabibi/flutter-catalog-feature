import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/flutter_catalog_feature.dart';

void main() {
  test('public entry point exposes primary entities and widgets', () {
    final group = GroupEntity(id: 'g1', name: 'Group');
    final item = CatalogItemEntity(id: 'i1', groupId: 'g1', name: 'Item');
    expect(group.name, 'Group');
    expect(item.name, 'Item');
    expect(CatalogFeature, isA<Type>());
    expect(CatalogPage, isA<Type>());
    expect(FavoritesView, isA<Type>());
    expect(FavoriteButton, isA<Type>());
    expect(initCatalogDependencies, isA<Function>());
  });
}
