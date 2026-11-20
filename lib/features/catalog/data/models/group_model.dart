import '../../../../core/extensions/map_extensions.dart';
import '../../domain/entities/group_entity.dart';

class GroupModel extends GroupEntity {
  GroupModel({
    required super.id,
    required super.name,
    super.description,
    super.imageUrl,
    super.sortOrder,
    super.isActive,
    super.createdAt,
    super.updatedAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json.asString('id'),
      name: json.asString('name'),
      description: json.asStringNullable('description'),
      imageUrl: json.asStringNullable('imageUrl'),
      sortOrder: json.asInt('sortOrder'),
      isActive: json.asBool('isActive', true),
      createdAt: json.asDateTimeNullable('createdAt'),
      updatedAt: json.asDateTimeNullable('updatedAt'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
