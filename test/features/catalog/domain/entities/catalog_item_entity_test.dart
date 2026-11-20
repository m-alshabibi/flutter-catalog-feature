import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/catalog_item_entity.dart';

void main() {
  test('copies gallery into an unmodifiable list', () {
    final gallery = ['a', 'b'];
    final item = CatalogItemEntity(id: 'i1', groupId: 'g1', name: 'Item', gallery: gallery);
    gallery.add('c');
    expect(item.gallery, ['a', 'b']);
    expect(() => item.gallery.add('d'), throwsUnsupportedError);
  });

  test('validates group ID and item name', () {
    expect(() => CatalogItemEntity(id: 'i1', groupId: ' ', name: 'Item'), throwsArgumentError);
    expect(() => CatalogItemEntity(id: 'i1', groupId: 'g1', name: ' '), throwsArgumentError);
  });
}
