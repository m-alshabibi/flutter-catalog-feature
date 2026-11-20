import '../../../../core/domain/entities/base_entity.dart';

class FavoriteEntity extends BaseEntity {
  final String userId;
  final String catalogItemId;

  FavoriteEntity({
    required super.id,
    required this.userId,
    required this.catalogItemId,
    super.createdAt,
    super.updatedAt,
  }) {
    if (userId.trim().isEmpty) {
      throw ArgumentError.value(
        userId,
        'userId',
        'Favorite user ID cannot be empty.',
      );
    }

    if (catalogItemId.trim().isEmpty) {
      throw ArgumentError.value(
        catalogItemId,
        'catalogItemId',
        'Favorite catalog item ID cannot be empty.',
      );
    }
  }
}
