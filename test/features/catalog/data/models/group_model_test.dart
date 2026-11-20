import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/features/catalog/data/models/group_model.dart';

void main() {
  test('round-trips a group through JSON', () {
    final source = GroupModel(
      id: 'g1', name: 'Services', description: 'All services',
      imageUrl: 'https://example.com/g.png', sortOrder: 3,
      createdAt: DateTime.utc(2025), updatedAt: DateTime.utc(2025, 2),
    );
    final parsed = GroupModel.fromJson(source.toJson());
    expect(parsed.id, source.id);
    expect(parsed.name, source.name);
    expect(parsed.description, source.description);
    expect(parsed.imageUrl, source.imageUrl);
    expect(parsed.sortOrder, 3);
    expect(parsed.createdAt, source.createdAt);
    expect(parsed.updatedAt, source.updatedAt);
  });

  test('uses model defaults for omitted optional values', () {
    final model = GroupModel.fromJson({'id': 'g1', 'name': 'Group'});
    expect(model.sortOrder, 0);
    expect(model.isActive, isTrue);
    expect(model.description, isNull);
  });
}
