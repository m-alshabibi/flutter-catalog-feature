import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/domain/entities/base_entity.dart';

class TestEntity extends BaseEntity {
  TestEntity({required super.id, super.createdAt, super.updatedAt});
}

class OtherTestEntity extends BaseEntity {
  OtherTestEntity({required super.id});
}

void main() {
  group('BaseEntity', () {
    test('rejects an empty or whitespace-only ID', () {
      expect(() => TestEntity(id: ''), throwsArgumentError);
      expect(() => TestEntity(id: '   '), throwsArgumentError);
    });

    test('uses supplied timestamps', () {
      final created = DateTime.utc(2025);
      final updated = DateTime.utc(2025, 2);
      final entity = TestEntity(id: 'id', createdAt: created, updatedAt: updated);
      expect(entity.createdAt, created);
      expect(entity.updatedAt, updated);
    });

    test('defaults timestamps and compares by runtime type and ID', () {
      final first = TestEntity(id: 'same');
      final second = TestEntity(id: 'same');
      expect(first.createdAt, isA<DateTime>());
      expect(first.updatedAt, isA<DateTime>());
      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(first, isNot(OtherTestEntity(id: 'same')));
    });
  });
}
