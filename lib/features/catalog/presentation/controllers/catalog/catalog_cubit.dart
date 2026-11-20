import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/domain/usecases/no_params.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/result/result.dart';
import '../../../domain/entities/catalog_item_entity.dart';
import '../../../domain/entities/group_entity.dart';
import '../../../domain/usecases/get_catalog_items_use_case.dart';
import '../../../domain/usecases/get_groups_use_case.dart';
import '../../../domain/usecases/refresh_catalog_items_by_group_use_case.dart';
import '../../../domain/usecases/refresh_groups_use_case.dart';
import 'catalog_state.dart';
import 'group_catalog_state.dart';

/// Manages catalog groups and their independently loaded items.
class CatalogCubit extends Cubit<CatalogState> {
  final GetGroupsUseCase _getGroupsUseCase;
  final RefreshGroupsUseCase _refreshGroupsUseCase;
  final GetCatalogItemsUseCase _getCatalogItemsUseCase;
  final RefreshCatalogItemsByGroupUseCase _refreshCatalogItemsByGroupUseCase;

  /// Prevents duplicate requests for the same group.
  final Set<String> _loadingGroupIds = {};

  CatalogCubit({
    required this._getGroupsUseCase,
    required this._refreshGroupsUseCase,
    required this._getCatalogItemsUseCase,
    required this._refreshCatalogItemsByGroupUseCase,
  }) : super(CatalogState());

  /// Loads groups locally first, then attempts remote synchronization.
  Future<void> loadCatalog() async {
    if (isClosed || state.isLoading || state.hasLoaded) {
      return;
    }

    await _loadGroups();
  }

  Future<void> _loadGroups() async {
    emit(state.copyWith(isLoading: true, clearFailure: true));

    var hasLocalData = false;

    try {
      final localResult = await _getGroupsUseCase(const NoParams());
      if (isClosed) return;

      if (localResult is Success<List<GroupEntity>>) {
        hasLocalData = true;

        emit(
          state.copyWith(
            groups: localResult.data,
            hasLoaded: true,
            isLoading: false,
            isRefreshing: true,
            clearFailure: true,
          ),
        );
      }

      // Cached data remains available if remote synchronization fails.
      final refreshResult = await _refreshGroupsUseCase(const NoParams());
      if (isClosed) return;

      if (refreshResult is Success<void>) {
        final updatedResult = await _getGroupsUseCase(const NoParams());
        if (isClosed) return;

        if (updatedResult is Success<List<GroupEntity>>) {
          _emitGroups(updatedResult.data);
        } else if (!hasLocalData) {
          _emitGroupsFailure(_failureOf(updatedResult));
        }
      } else if (!hasLocalData) {
        _emitGroupsFailure(_failureOf(refreshResult));
      }
    } finally {
      if (!isClosed) {
        emit(state.copyWith(isLoading: false, isRefreshing: false));
      }
    }
  }

  /// Loads one group's items independently.
  ///
  /// Can be called when a group approaches the visible area.
  Future<void> loadGroupItems(
    String groupId, {
    bool forceRefresh = false,
  }) async {
    if (isClosed ||
        _loadingGroupIds.contains(groupId) ||
        !_containsGroup(groupId)) {
      return;
    }

    final currentGroupState = state.groupState(groupId);

    if (currentGroupState.hasLoaded && !forceRefresh) {
      return;
    }

    _loadingGroupIds.add(groupId);

    _updateGroupState(
      groupId,
      currentGroupState.copyWith(
        isLoading: !currentGroupState.hasLoaded,
        isRefreshing: currentGroupState.hasLoaded,
        clearFailure: true,
      ),
    );

    var hasLocalData = false;

    try {
      final localResult = await _getCatalogItemsUseCase(groupId);
      if (isClosed) return;

      if (localResult is Success<List<CatalogItemEntity>>) {
        hasLocalData = true;

        _updateGroupState(
          groupId,
          state
              .groupState(groupId)
              .copyWith(
                items: localResult.data,
                hasLoaded: true,
                isLoading: false,
                isRefreshing: true,
                clearFailure: true,
              ),
        );
      }

      // Synchronize only the requested group.
      final refreshResult = await _refreshCatalogItemsByGroupUseCase(groupId);
      if (isClosed) return;

      if (refreshResult is Success<void>) {
        final updatedResult = await _getCatalogItemsUseCase(groupId);
        if (isClosed) return;

        if (updatedResult is Success<List<CatalogItemEntity>>) {
          _updateGroupState(
            groupId,
            state
                .groupState(groupId)
                .copyWith(
                  items: updatedResult.data,
                  hasLoaded: true,
                  isLoading: false,
                  isRefreshing: false,
                  clearFailure: true,
                ),
          );
        } else if (!hasLocalData) {
          _setGroupFailure(groupId, _failureOf(updatedResult));
        }
      } else if (!hasLocalData) {
        _setGroupFailure(groupId, _failureOf(refreshResult));
      }
    } finally {
      _loadingGroupIds.remove(groupId);

      if (!isClosed && _containsGroup(groupId)) {
        _updateGroupState(
          groupId,
          state
              .groupState(groupId)
              .copyWith(isLoading: false, isRefreshing: false),
        );
      }
    }
  }

  /// Refreshes groups and previously loaded group items.
  ///
  /// Unloaded groups remain unloaded. Loaded groups are refreshed
  /// sequentially to avoid sending an unrestricted burst of requests.
  Future<void> refreshCatalog() async {
    if (isClosed || state.isRefreshing || state.isLoading) {
      return;
    }

    if (!state.hasLoaded) {
      await loadCatalog();
      return;
    }

    emit(state.copyWith(isRefreshing: true));

    try {
      final refreshResult = await _refreshGroupsUseCase(const NoParams());
      if (isClosed) return;

      if (refreshResult is Success<void>) {
        final groupsResult = await _getGroupsUseCase(const NoParams());
        if (isClosed) return;

        if (groupsResult is Success<List<GroupEntity>>) {
          _emitGroups(groupsResult.data);
        } else if (state.groups.isEmpty) {
          emit(state.copyWith(failure: _failureOf(groupsResult)));
        }
      } else if (state.groups.isEmpty) {
        emit(state.copyWith(failure: _failureOf(refreshResult)));
      }

      if (isClosed) return;

      // Take the snapshot after refreshing groups, excluding removed groups.
      final loadedGroupIds = state.catalogByGroupId.entries
          .where((entry) => entry.value.hasLoaded)
          .map((entry) => entry.key)
          .toList(growable: false);

      for (final groupId in loadedGroupIds) {
        if (isClosed) break;

        await loadGroupItems(groupId, forceRefresh: true);
      }
    } finally {
      if (!isClosed) {
        emit(state.copyWith(isRefreshing: false));
      }
    }
  }

  /// Retries loading groups after an initial failure.
  Future<void> retryLoadGroups() async {
    if (isClosed || state.isLoading || state.isRefreshing) {
      return;
    }

    await _loadGroups();
  }

  /// Retries loading or refreshing one group's items.
  Future<void> retryLoadGroupItems(String groupId) {
    return loadGroupItems(groupId, forceRefresh: true);
  }

  bool _containsGroup(String groupId) {
    return state.groups.any((group) => group.id == groupId);
  }

  void _emitGroups(List<GroupEntity> groups) {
    if (isClosed) return;

    final validGroupIds = groups.map((group) => group.id).toSet();

    final retainedStates = Map<String, GroupCatalogState>.from(
      state.catalogByGroupId,
    )..removeWhere((id, _) => !validGroupIds.contains(id));

    emit(
      state.copyWith(
        groups: groups,
        catalogByGroupId: retainedStates,
        hasLoaded: true,
        isLoading: false,
        clearFailure: true,
      ),
    );
  }

  void _emitGroupsFailure(Failure failure) {
    if (isClosed) return;

    emit(state.copyWith(failure: failure, isLoading: false));
  }

  void _updateGroupState(String groupId, GroupCatalogState groupState) {
    if (isClosed || !_containsGroup(groupId)) return;

    final updatedStates = Map<String, GroupCatalogState>.from(
      state.catalogByGroupId,
    )..[groupId] = groupState;

    emit(state.copyWith(catalogByGroupId: updatedStates));
  }

  void _setGroupFailure(String groupId, Failure failure) {
    _updateGroupState(
      groupId,
      state
          .groupState(groupId)
          .copyWith(failure: failure, isLoading: false, isRefreshing: false),
    );
  }

  Failure _failureOf<T>(Result<T> result) {
    if (result is FailureResult<T>) {
      return result.failure;
    }

    return const UnknownFailure();
  }
}
