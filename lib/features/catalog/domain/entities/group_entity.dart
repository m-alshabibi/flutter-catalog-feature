import '../../../../core/domain/entities/base_entity.dart';

class GroupEntity extends BaseEntity {
  final String name;
  final String? description;
  final String? imageUrl;
  final int sortOrder;
  final bool isActive;

  GroupEntity({
    required super.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.sortOrder = 0,
    this.isActive = true,
    super.createdAt,
    super.updatedAt,
  }) {
    if (name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name', 'Group name cannot be empty.');
    }
  }
}
