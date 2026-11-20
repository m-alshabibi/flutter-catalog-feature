import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/presentation/widgets/app_grid_view.dart';

void main() {
  testWidgets('renders grid items and forwards tap callbacks', (tester) async {
    final tapped = <int>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AppGridView<int>(
          items: const [1, 2, 3],
          crossAxisCount: 2,
          itemBuilder: (_, value) => Text('item-$value'),
          onItemTap: tapped.add,
        ),
      ),
    ));

    expect(find.text('item-1'), findsOneWidget);
    await tester.tap(find.text('item-3'));
    expect(tapped, [3]);
  });

  test('rejects a non-positive cross axis count', () {
    expect(
      () => AppGridView<int>(items: const [], crossAxisCount: 0, itemBuilder: (_, value) => Text('$value')),
      throwsAssertionError,
    );
  });
}
