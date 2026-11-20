import '../../../../../core/error/failures.dart';
import '../../../domain/entities/catalog_item_entity.dart';
import '../base/base_load_state.dart';

/// Holds the state of a single catalog item's details.
class CatalogItemDetailsState extends BaseLoadState {
  final CatalogItemEntity? item;

  const CatalogItemDetailsState({
    this.item,
    super.hasLoaded,
    super.isLoading,
    super.isRefreshing,
    super.failure,
  });

  CatalogItemDetailsState copyWith({
    CatalogItemEntity? item,
    bool clearItem = false,
    bool? hasLoaded,
    bool? isLoading,
    bool? isRefreshing,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return CatalogItemDetailsState(
      item: clearItem ? null : item ?? this.item,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }
}
