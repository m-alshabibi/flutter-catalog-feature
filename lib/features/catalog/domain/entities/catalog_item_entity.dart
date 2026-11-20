import '../../../../core/domain/entities/base_entity.dart';

class CatalogItemEntity extends BaseEntity {
  final String groupId;
  final String name;
  final String? shortDescription;
  final String? longDescription;
  final String? imageUrl;
  final List<String> gallery;
  final int sortOrder;
  final bool isActive;
  final bool isFeatured;
  final Map<String, dynamic>? metadata;

  CatalogItemEntity({
    required super.id,
    required this.groupId,
    required this.name,
    this.shortDescription,
    this.longDescription,
    this.imageUrl,
    List<String> gallery = const [],
    this.sortOrder = 0,
    this.isActive = true,
    this.isFeatured = false,
    this.metadata,
    super.createdAt,
    super.updatedAt,
  }) : gallery = List.unmodifiable(gallery) {
    if (groupId.trim().isEmpty) {
      throw ArgumentError.value(
        groupId,
        'groupId',
        'Catalog item group ID cannot be empty.',
      );
    }

    if (name.trim().isEmpty) {
      throw ArgumentError.value(
        name,
        'name',
        'Catalog item name cannot be empty.',
      );
    }
  }
}
