import '../entities/catalog_item_entity.dart';
import '../entities/group_entity.dart';

class GroupWithCatalog {
  final GroupEntity group;
  final List<CatalogItemEntity> catalogItems;

  GroupWithCatalog({
    required this.group,
    required List<CatalogItemEntity> catalogItems,
  }) : catalogItems = List.unmodifiable(catalogItems);
}
