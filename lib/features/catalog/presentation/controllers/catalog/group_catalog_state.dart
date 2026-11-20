import '../../../../../core/error/failures.dart';
import '../../../domain/entities/catalog_item_entity.dart';
import '../base/base_load_state.dart';

/// Holds the data and loading state of a single catalog group.
class GroupCatalogState extends BaseLoadState {
  final List<CatalogItemEntity> items;

  GroupCatalogState({
    List<CatalogItemEntity> items = const [],
    super.hasLoaded = false,
    super.isLoading = false,
    super.isRefreshing = false,
    super.failure,
  }) : items = List.unmodifiable(items);

  GroupCatalogState copyWith({
    List<CatalogItemEntity>? items,
    bool? hasLoaded,
    bool? isLoading,
    bool? isRefreshing,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return GroupCatalogState(
      items: items ?? this.items,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }
}
