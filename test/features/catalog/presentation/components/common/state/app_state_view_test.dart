import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/error/failures.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/components/common/state/app_state_view.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/components/common/state/empty_view.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/components/common/state/error_view.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/components/common/state/loading_view.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/base/base_load_state.dart';

class TestState extends BaseLoadState {
  const TestState({
    super.hasLoaded,
    super.isLoading,
    super.isRefreshing,
    super.failure,
  });
}

void main() {
  Widget buildSubject({
    required TestState state,
    required bool isEmpty,
    Widget Function(TestState state)? contentBuilder,
    Widget? loadingWidget,
    Widget? emptyWidget,
    Widget Function(Failure failure)? errorBuilder,
    VoidCallback? onRetry,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: AppStateView<TestState>(
          state: state,
          isEmpty: isEmpty,
          contentBuilder: contentBuilder ?? (_) => const Text('Content'),
          loadingWidget: loadingWidget,
          emptyWidget: emptyWidget,
          errorBuilder: errorBuilder,
          onRetry: onRetry,
        ),
      ),
    );
  }

  group('AppStateView', () {
    testWidgets('should show loading during initial loading', (tester) async {
      await tester.pumpWidget(
        buildSubject(state: const TestState(isLoading: true), isEmpty: false),
      );

      expect(find.byType(LoadingView), findsOneWidget);
      expect(find.text('Content'), findsNothing);
    });

    testWidgets('should show error when initial loading fails', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          state: const TestState(failure: UnknownFailure()),
          isEmpty: false,
        ),
      );

      expect(find.byType(ErrorView), findsOneWidget);
    });

    testWidgets('should use custom error builder when provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(
          state: const TestState(failure: UnknownFailure()),
          isEmpty: false,
          errorBuilder: (_) => const Text('Custom error'),
        ),
      );

      expect(find.text('Custom error'), findsOneWidget);
      expect(find.byType(ErrorView), findsNothing);
    });

    testWidgets('should show empty view after successful empty loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(state: const TestState(hasLoaded: true), isEmpty: true),
      );

      expect(find.byType(EmptyView), findsOneWidget);
    });

    testWidgets('should use custom empty widget when provided', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          state: const TestState(hasLoaded: true),
          isEmpty: true,
          emptyWidget: const Text('Nothing here'),
        ),
      );

      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.byType(EmptyView), findsNothing);
    });

    testWidgets('should show content when data is available', (tester) async {
      await tester.pumpWidget(
        buildSubject(state: const TestState(hasLoaded: true), isEmpty: false),
      );

      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('should keep content visible during refresh', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          state: const TestState(hasLoaded: true, isRefreshing: true),
          isEmpty: false,
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(LoadingView), findsNothing);
    });

    testWidgets('should keep cached content visible when refresh fails', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(
          state: const TestState(hasLoaded: true, failure: UnknownFailure()),
          isEmpty: false,
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(ErrorView), findsNothing);
    });
  });
}
