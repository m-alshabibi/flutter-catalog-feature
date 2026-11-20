import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/group_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/widgets/groups/group_item.dart';

void main() {
  late GroupEntity group;

  setUp(() {
    group = GroupEntity(
      id: 'group-1',
      name: 'Electronics',
      description: 'Electronic devices and accessories',
      imageUrl: null,
    );
  });

  Widget buildTestWidget({Widget? child}) {
    return MaterialApp(
      home: Scaffold(body: child ?? GroupItem(group: group)),
    );
  }

  testWidgets('should display group name', (tester) async {
    await tester.pumpWidget(buildTestWidget());

    expect(find.text('Electronics'), findsOneWidget);
  });

  testWidgets('should display group description when available', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestWidget());

    expect(find.text('Electronic devices and accessories'), findsOneWidget);
  });

  testWidgets('should not display description when null', (tester) async {
    final emptyDescriptionGroup = GroupEntity(
      id: 'group-1',
      name: 'Electronics',
    );

    await tester.pumpWidget(
      buildTestWidget(child: GroupItem(group: emptyDescriptionGroup)),
    );

    expect(find.text('Electronics'), findsOneWidget);
    expect(find.text('Electronic devices and accessories'), findsNothing);
  });

  testWidgets('should display image when imageUrl is available', (
    tester,
  ) async {
    final imageGroup = GroupEntity(
      id: 'group-1',
      name: 'Electronics',
      imageUrl: 'https://example.com/image.jpg',
    );

    await tester.pumpWidget(
      buildTestWidget(child: GroupItem(group: imageGroup)),
    );

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('should call onTap when tapped', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      buildTestWidget(
        child: GroupItem(group: group, onTap: () => tapped = true),
      ),
    );

    await tester.tap(find.byType(InkWell));

    expect(tapped, isTrue);
  });

  testWidgets('should use custom builder when provided', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        child: GroupItem(
          group: group,
          builder: (context, group) {
            return Text('Custom: ${group.name}');
          },
        ),
      ),
    );

    expect(find.text('Custom: Electronics'), findsOneWidget);
    expect(find.byType(Card), findsNothing);
  });
}
