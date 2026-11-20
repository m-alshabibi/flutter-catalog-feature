import '../../domain/entities/catalog_item_entity.dart';
import '../../domain/models/catalog_item_with_favorite.dart';

/// Catalog items grouped by their group ID.
typedef CatalogItemsByGroup = Map<String, List<CatalogItemEntity>>;

/// A list of catalog items with their favorite status.
typedef CatalogItemsWithFavorite = List<CatalogItemWithFavorite>;

/// Catalog items with favorite status, grouped by group ID.
typedef CatalogItemsWithFavoriteByGroup = Map<String, CatalogItemsWithFavorite>;
