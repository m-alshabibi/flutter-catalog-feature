import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/features/catalog/data/models/catalog_item_model.dart';

void main() {
  test('round-trips catalog item fields through JSON', () {
    final source = CatalogItemModel(
      id: 'i1', groupId: 'g1', name: 'Item',
      gallery: const ['one', 'two'], metadata: const {'color': 'blue'},
      createdAt: DateTime.utc(2025), updatedAt: DateTime.utc(2025, 2),
    );
    final parsed = CatalogItemModel.fromJson(source.toJson());
    expect(parsed.id, source.id);
    expect(parsed.groupId, source.groupId);
    expect(parsed.name, source.name);
    expect(parsed.gallery, source.gallery);
    expect(parsed.metadata, source.metadata);
    expect(parsed.isFeatured, source.isFeatured);
    expect(parsed.createdAt, source.createdAt);
  });

  test('defaults missing lists and flags', () {
    final model = CatalogItemModel.fromJson({'id': 'i1', 'groupId': 'g1', 'name': 'Item'});
    expect(model.gallery, isEmpty);
    expect(model.isActive, isTrue);
    expect(model.isFeatured, isFalse);
  });
}
