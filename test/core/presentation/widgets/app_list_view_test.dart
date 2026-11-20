import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/presentation/widgets/app_list_view.dart';

void main() {
  testWidgets('renders list items and forwards tap callbacks', (tester) async {
    final tapped = <String>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AppListView<String>(
          items: const ['one', 'two'],
          itemBuilder: (_, value) => Text(value),
          onItemTap: tapped.add,
        ),
      ),
    ));

    expect(find.text('one'), findsOneWidget);
    expect(find.text('two'), findsOneWidget);
    await tester.tap(find.text('two'));
    expect(tapped, ['two']);
  });

  testWidgets('supports an empty collection', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: AppListView<int>(items: [], itemBuilder: _emptyBuilder)),
    ));
    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
  });
}

Widget _emptyBuilder(BuildContext context, int value) => Text('$value');
