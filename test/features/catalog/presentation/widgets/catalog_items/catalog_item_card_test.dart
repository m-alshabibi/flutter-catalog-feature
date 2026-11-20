import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/catalog_item_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/widgets/catalog_items/catalog_item_card.dart';

CatalogItemEntity createItem({
  String name = 'Test Item',
  String? shortDescription = 'Test description',
  String? imageUrl,
}) {
  return CatalogItemEntity(
    id: 'item-1',
    groupId: 'group-1',
    name: name,
    shortDescription: shortDescription,
    imageUrl: imageUrl,
  );
}

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('CatalogItemCard', () {
    testWidgets('should display item name and description', (tester) async {
      final item = createItem();

      await tester.pumpWidget(buildTestWidget(CatalogItemCard(item: item)));

      expect(find.text('Test Item'), findsOneWidget);
      expect(find.text('Test description'), findsOneWidget);
    });

    testWidgets('should not display description when null', (tester) async {
      final item = createItem(shortDescription: null);

      await tester.pumpWidget(buildTestWidget(CatalogItemCard(item: item)));

      expect(find.text('Test Item'), findsOneWidget);
      expect(find.text('Test description'), findsNothing);
    });

    testWidgets('should display image when imageUrl is provided', (
      tester,
    ) async {
      final item = createItem(imageUrl: 'https://example.com/image.png');

      await tester.pumpWidget(buildTestWidget(CatalogItemCard(item: item)));

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        buildTestWidget(
          CatalogItemCard(item: createItem(), onTap: () => tapped = true),
        ),
      );

      await tester.tap(find.text('Test Item'));

      expect(tapped, isTrue);
    });

    testWidgets('should use custom builder when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          CatalogItemCard(
            item: createItem(),
            builder: (context, item) {
              return Text('Custom: ${item.name}');
            },
          ),
        ),
      );

      expect(find.text('Custom: Test Item'), findsOneWidget);
      expect(find.byType(Card), findsNothing);
    });
  });
}
