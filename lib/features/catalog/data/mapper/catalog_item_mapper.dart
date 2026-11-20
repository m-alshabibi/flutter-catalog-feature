import 'dart:convert';

import 'package:drift/drift.dart';

import '../datasources/local/database/app_database.dart';
import '../models/catalog_item_model.dart';

class CatalogItemMapper {
  static CatalogItemModel mapToModel(CatalogItemsTableData row) {
    return CatalogItemModel(
      id: row.id,
      groupId: row.groupId,
      name: row.name,
      shortDescription: row.shortDescription,
      longDescription: row.longDescription,
      imageUrl: row.imageUrl,
      gallery: row.gallery,
      sortOrder: row.sortOrder,
      isActive: row.isActive,
      isFeatured: row.isFeatured,
      metadata: row.metadata == null
          ? null
          : Map<String, dynamic>.from(jsonDecode(row.metadata!) as Map),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static Insertable<CatalogItemsTableData> modelToMap(CatalogItemModel item) {
    return CatalogItemsTableCompanion.insert(
      id: item.id,
      groupId: item.groupId,
      name: item.name,
      shortDescription: Value(item.shortDescription),
      longDescription: Value(item.longDescription),
      imageUrl: Value(item.imageUrl),
      gallery: item.gallery,
      sortOrder: Value(item.sortOrder),
      isActive: Value(item.isActive),
      isFeatured: Value(item.isFeatured),
      metadata: Value(item.metadata == null ? null : jsonEncode(item.metadata)),
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    );
  }
}
