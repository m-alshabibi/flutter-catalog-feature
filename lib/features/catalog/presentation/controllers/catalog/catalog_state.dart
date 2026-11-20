import '../../../../../core/error/failures.dart';
import '../../../domain/entities/group_entity.dart';
import '../base/base_load_state.dart';
import 'group_catalog_state.dart';

/// Holds the state of the main catalog screen.
class CatalogState extends BaseLoadState {
  final List<GroupEntity> groups;

  /// Keeps each group's state independent, indexed by group ID.
  final Map<String, GroupCatalogState> catalogByGroupId;

  CatalogState({
    List<GroupEntity> groups = const [],
    Map<String, GroupCatalogState> catalogByGroupId = const {},
    super.hasLoaded = false,
    super.isLoading = false,
    super.isRefreshing = false,
    super.failure,
  }) : groups = List.unmodifiable(groups),
       catalogByGroupId = Map.unmodifiable(catalogByGroupId);

  CatalogState copyWith({
    List<GroupEntity>? groups,
    Map<String, GroupCatalogState>? catalogByGroupId,
    bool? hasLoaded,
    bool? isLoading,
    bool? isRefreshing,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return CatalogState(
      groups: groups ?? this.groups,
      catalogByGroupId: catalogByGroupId ?? this.catalogByGroupId,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }

  /// Returns an empty state when the group has not been requested yet.
  GroupCatalogState groupState(String groupId) {
    return catalogByGroupId[groupId] ?? GroupCatalogState();
  }
}
