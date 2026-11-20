import '../../../../core/extensions/map_extensions.dart';
import '../../domain/entities/catalog_item_entity.dart';

class CatalogItemModel extends CatalogItemEntity {
  CatalogItemModel({
    required super.id,
    required super.groupId,
    required super.name,
    super.shortDescription,
    super.longDescription,
    super.imageUrl,
    super.gallery,
    super.sortOrder,
    super.isActive,
    super.isFeatured,
    super.metadata,
    super.createdAt,
    super.updatedAt,
  });

  factory CatalogItemModel.fromJson(Map<String, dynamic> json) {
    return CatalogItemModel(
      id: json.asString('id'),
      groupId: json.asString('groupId'),
      name: json.asString('name'),
      shortDescription: json.asStringNullable('shortDescription'),
      longDescription: json.asStringNullable('longDescription'),
      imageUrl: json['imageUrl'] as String?,
      gallery: json.asStringList('gallery'),
      sortOrder: json.asInt('sortOrder'),
      isActive: json.asBool('isActive', true),
      isFeatured: json.asBool('isFeatured'),
      metadata: json.asMapNullable<String, dynamic>('metadata'),
      createdAt: json.asDateTimeNullable('createdAt'),
      updatedAt: json.asDateTimeNullable('updatedAt'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'name': name,
      'shortDescription': shortDescription,
      'longDescription': longDescription,
      'imageUrl': imageUrl,
      'gallery': gallery,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
