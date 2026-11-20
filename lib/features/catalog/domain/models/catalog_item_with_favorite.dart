import '../entities/catalog_item_entity.dart';

class CatalogItemWithFavorite {
  final CatalogItemEntity catalogItem;
  final bool isFavorite;

  const CatalogItemWithFavorite({
    required this.catalogItem,
    required this.isFavorite,
  });
}
