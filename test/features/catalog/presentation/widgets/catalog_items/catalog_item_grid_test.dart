import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/catalog_item_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/widgets/catalog_items/catalog_item_card.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/widgets/catalog_items/catalog_item_grid.dart';

CatalogItemEntity createItem(String id, String name) {
  return CatalogItemEntity(id: id, groupId: 'group-1', name: name);
}

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  final items = [
    createItem('1', 'Item One'),
    createItem('2', 'Item Two'),
    createItem('3', 'Item Three'),
    createItem('4', 'Item Four'),
  ];

  testWidgets('should display all items', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(CatalogItemGrid(items: items, shrinkWrap: true)),
    );

    for (final item in items) {
      expect(find.text(item.name), findsOneWidget);
    }
  });

  testWidgets('should display empty grid', (tester) async {
    await tester.pumpWidget(buildTestWidget(const CatalogItemGrid(items: [])));

    expect(find.byType(GridView), findsOneWidget);
    expect(find.byType(CatalogItemCard), findsNothing);
  });

  testWidgets('should use custom crossAxisCount', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        CatalogItemGrid(items: items, crossAxisCount: 3, shrinkWrap: true),
      ),
    );

    final grid = tester.widget<GridView>(find.byType(GridView));
    final delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

    expect(delegate.crossAxisCount, 3);
  });

  testWidgets('should call onItemTap with selected item', (tester) async {
    CatalogItemEntity? selectedItem;

    await tester.pumpWidget(
      buildTestWidget(
        CatalogItemGrid(
          items: items,
          shrinkWrap: true,
          onItemTap: (item) => selectedItem = item,
        ),
      ),
    );

    await tester.tap(find.text('Item Two'));

    expect(selectedItem?.id, '2');
  });

  testWidgets('should use custom item builder', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        CatalogItemGrid(
          items: items,
          shrinkWrap: true,
          itemBuilder: (_, item) => Text('Custom ${item.name}'),
        ),
      ),
    );

    expect(find.text('Custom Item One'), findsOneWidget);
  });
}
