import '../../../../../core/error/failures.dart';

abstract class BaseLoadState {
  /// Distinguishes an unloaded group from a successfully loaded empty group.
  final bool hasLoaded;

  /// Initial loading when no cached data is available.
  final bool isLoading;

  /// Refreshing while keeping existing items visible.
  final bool isRefreshing;
  final Failure? failure;

  const BaseLoadState({
    this.hasLoaded = false,
    this.isLoading = false,
    this.isRefreshing = false,
    this.failure,
  });
}
