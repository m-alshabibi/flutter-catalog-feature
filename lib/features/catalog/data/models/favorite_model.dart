import '../../../../core/extensions/map_extensions.dart';
import '../../domain/entities/favorite_entity.dart';

class FavoriteModel extends FavoriteEntity {
  FavoriteModel({
    required super.id,
    required super.userId,
    required super.catalogItemId,
    super.createdAt,
    super.updatedAt,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json.asString('id'),
      userId: json.asString('userId'),
      catalogItemId: json.asString('catalogItemId'),
      createdAt: json.asDateTimeNullable('createdAt'),
      updatedAt: json.asDateTimeNullable('updatedAt'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'catalogItemId': catalogItemId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
