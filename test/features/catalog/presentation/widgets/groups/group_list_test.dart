import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/group_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/widgets/groups/group_item.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/widgets/groups/group_list.dart';

void main() {
  late List<GroupEntity> groups;

  setUp(() {
    groups = [
      GroupEntity(id: 'group-1', name: 'Electronics'),
      GroupEntity(id: 'group-2', name: 'Clothing'),
      GroupEntity(id: 'group-3', name: 'Books'),
    ];
  });

  Widget buildTestWidget({required Widget child}) {
    return MaterialApp(
      home: Scaffold(body: SizedBox(height: 500, child: child)),
    );
  }

  testWidgets('should display all groups', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(child: GroupList(groups: groups, shrinkWrap: true)),
    );

    for (final group in groups) {
      expect(find.text(group.name), findsOneWidget);
    }
  });

  testWidgets('should display an empty list when groups are empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(child: const GroupList(groups: [])),
    );

    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(GroupItem), findsNothing);
  });

  testWidgets('should call onGroupTap with the tapped group', (tester) async {
    GroupEntity? selectedGroup;

    await tester.pumpWidget(
      buildTestWidget(
        child: GroupList(
          groups: groups,
          shrinkWrap: true,
          onGroupTap: (group) => selectedGroup = group,
        ),
      ),
    );

    await tester.tap(find.text('Clothing'));

    expect(selectedGroup, same(groups[1]));
  });

  testWidgets('should use custom itemBuilder', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        child: GroupList(
          groups: groups,
          shrinkWrap: true,
          itemBuilder: (context, group) {
            return Text('Custom: ${group.name}');
          },
        ),
      ),
    );

    expect(find.text('Custom: Electronics'), findsOneWidget);
    expect(find.text('Custom: Clothing'), findsOneWidget);
    expect(find.text('Custom: Books'), findsOneWidget);
  });

  testWidgets('should support horizontal scrolling', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        child: GroupList(groups: groups, scrollDirection: Axis.horizontal),
      ),
    );

    final listView = tester.widget<ListView>(find.byType(ListView));

    expect(listView.scrollDirection, Axis.horizontal);
  });

  testWidgets('should use the provided spacing', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        child: GroupList(groups: groups, shrinkWrap: true, spacing: 16),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.height == 16,
      ),
      findsNWidgets(2),
    );
  });
}
