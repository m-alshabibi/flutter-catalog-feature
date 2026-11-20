import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/group_entity.dart';

void main() {
  test('creates a group with defaults and supplied fields', () {
    final group = GroupEntity(id: 'g1', name: 'Services');
    expect(group.id, 'g1');
    expect(group.name, 'Services');
    expect(group.sortOrder, 0);
    expect(group.isActive, isTrue);
    expect(group.description, isNull);
  });

  test('rejects an empty name', () {
    expect(() => GroupEntity(id: 'g1', name: '  '), throwsArgumentError);
  });
}
