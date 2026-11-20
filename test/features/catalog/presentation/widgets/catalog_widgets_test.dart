import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/widgets/groups/group_item.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/widgets/groups/group_list.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/widgets/groups/group_grid.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/widgets/catalog_items/catalog_item_card.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/widgets/catalog_items/catalog_item_list.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/widgets/catalog_items/catalog_item_grid.dart';
import '../../../../support/fixtures.dart';

void main() {
  testWidgets('GroupItem renders the group and invokes its tap callback', (tester) async {
    var tapped = false;
    final group = makeGroup();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: GroupItem(group: group, onTap: () => tapped = true)),
    ));
    expect(find.text(group.name), findsOneWidget);
    await tester.tap(find.byType(InkWell));
    expect(tapped, isTrue);
  });

  testWidgets('GroupList and GroupGrid render their collections', (tester) async {
    final groups = [makeGroup(), makeGroup(id: 'g2', name: 'Second')];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: GroupList(groups: groups)),
    ));
    expect(find.text('Group One'), findsOneWidget);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: GroupGrid(groups: groups, shrinkWrap: true)),
    ));
    expect(find.text('Second'), findsOneWidget);
  });

  testWidgets('CatalogItemCard renders name and description', (tester) async {
    final item = makeItem();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CatalogItemCard(
          item: item,
          builder: (_, value) => Text('${value.name}:${value.shortDescription}'),
        ),
      ),
    ));
    expect(find.text('Item One:Short description'), findsOneWidget);
  });

  testWidgets('CatalogItemList and CatalogItemGrid render item names', (tester) async {
    final items = [
      makeItem(imageUrl: null),
      makeItem(id: 'i2', name: 'Second', imageUrl: null),
    ];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: CatalogItemList(items: items)),
    ));
    expect(find.text('Item One'), findsOneWidget);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: CatalogItemGrid(items: items, shrinkWrap: true)),
    ));
    expect(find.text('Second'), findsOneWidget);
  });
}
