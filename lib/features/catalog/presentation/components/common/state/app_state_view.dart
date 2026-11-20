import 'package:flutter/material.dart';

import '../../../../../../core/error/failures.dart';
import '../../../controllers/base/base_load_state.dart';
import 'empty_view.dart';
import 'error_view.dart';
import 'loading_view.dart';

class AppStateView<T extends BaseLoadState> extends StatelessWidget {
  final T state;
  final bool isEmpty;
  final Widget Function(T state) contentBuilder;

  final VoidCallback? onRetry;

  /// Optional widgets for overriding the default presentation.
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final Widget Function(Failure failure)? errorBuilder;

  const AppStateView({
    super.key,
    required this.state,
    required this.isEmpty,
    required this.contentBuilder,
    this.onRetry,
    this.loadingWidget,
    this.emptyWidget,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    // Show initial loading only when no data has been loaded.
    if (!state.hasLoaded && state.isLoading) {
      return loadingWidget ?? const LoadingView();
    }

    // Show the initial error only when no cached data is available.
    if (!state.hasLoaded && state.failure != null) {
      return errorBuilder?.call(state.failure!) ??
          ErrorView(message: state.failure!.message, onRetry: onRetry);
    }

    // Empty is meaningful only after a successful load.
    if (state.hasLoaded && isEmpty) {
      return emptyWidget ?? const EmptyView();
    }

    // Keep existing content visible during refresh operations.
    return contentBuilder(state);
  }
}
