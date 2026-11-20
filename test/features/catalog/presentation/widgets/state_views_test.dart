import 'package:flutter/material.dart';
import 'package:flutter_catalog_feature/core/error/failures.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/components/common/state/app_state_view.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/base/base_load_state.dart';
import 'package:flutter_test/flutter_test.dart';

class TestLoadState extends BaseLoadState {
  const TestLoadState({super.hasLoaded, super.isLoading, super.failure});
}

void main() {
  testWidgets('shows loading while initial data is loading', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppStateView<TestLoadState>(
            state: TestLoadState(isLoading: true),
            isEmpty: false,
            contentBuilder: _content,
          ),
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows an initial failure and invokes retry', (tester) async {
    var retries = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppStateView<TestLoadState>(
            state: const TestLoadState(failure: NetworkFailure('offline')),
            isEmpty: false,
            contentBuilder: _content,
            onRetry: () => retries++,
          ),
        ),
      ),
    );
    expect(find.text('offline'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retries, 1);
  });

  testWidgets('shows empty state after a successful empty load', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppStateView<TestLoadState>(
            state: TestLoadState(hasLoaded: true),
            isEmpty: true,
            contentBuilder: _content,
          ),
        ),
      ),
    );
    expect(find.text('No items found.'), findsOneWidget);
  });

  testWidgets('keeps content visible when refreshing', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppStateView<TestLoadState>(
            state: TestLoadState(hasLoaded: true),
            isEmpty: false,
            contentBuilder: _content,
          ),
        ),
      ),
    );
    expect(find.text('content'), findsOneWidget);
  });
}

Widget _content(TestLoadState state) => const Text('content');
