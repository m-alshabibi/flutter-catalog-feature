import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/favorite_entity.dart';

void main() {
  test('creates a favorite with its user and item identifiers', () {
    final favorite = FavoriteEntity(id: 'f1', userId: 'u1', catalogItemId: 'i1');
    expect(favorite.userId, 'u1');
    expect(favorite.catalogItemId, 'i1');
  });

  test('rejects empty user and catalog item identifiers', () {
    expect(() => FavoriteEntity(id: 'f1', userId: '', catalogItemId: 'i1'), throwsArgumentError);
    expect(() => FavoriteEntity(id: 'f1', userId: 'u1', catalogItemId: ' '), throwsArgumentError);
  });
}
