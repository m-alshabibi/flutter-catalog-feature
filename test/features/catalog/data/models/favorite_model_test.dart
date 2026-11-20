import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/features/catalog/data/models/favorite_model.dart';

void main() {
  test('round-trips favorite JSON', () {
    final source = FavoriteModel(
      id: 'f1', userId: 'u1', catalogItemId: 'i1',
      createdAt: DateTime.utc(2025), updatedAt: DateTime.utc(2025, 2),
    );
    final parsed = FavoriteModel.fromJson(source.toJson());
    expect(parsed.id, 'f1');
    expect(parsed.userId, 'u1');
    expect(parsed.catalogItemId, 'i1');
    expect(parsed.createdAt, source.createdAt);
    expect(parsed.updatedAt, source.updatedAt);
  });
}
