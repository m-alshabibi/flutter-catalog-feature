import '../../../../core/result/result.dart';
import '../entities/catalog_item_entity.dart';

abstract interface class CatalogItemRepository {
  /// Retrieves all catalog items grouped by their group IDs.
  Future<Result<Map<String, List<CatalogItemEntity>>>> getAllCatalogItems();

  /// Retrieves catalog items belonging to a specific group.
  Future<Result<List<CatalogItemEntity>>> getCatalogItems(String groupId);

  /// Retrieves multiple catalog items by their IDs.
  Future<Result<List<CatalogItemEntity>>> getCatalogItemsByIds(Set<String> ids);

  /// Retrieves a catalog item by its ID.
  Future<Result<CatalogItemEntity>> getCatalogItemById(String id);

  /// Fetches all catalog items from the remote source
  /// and updates the local cache.
  Future<Result<void>> refreshCatalogItems();

  /// Fetches catalog items for a specific group
  /// and updates the local cache.
  Future<Result<void>> refreshCatalogItemsByGroup(String groupId);
}
