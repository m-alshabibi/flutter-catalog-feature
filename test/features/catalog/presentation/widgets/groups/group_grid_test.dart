import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/group_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/widgets/groups/group_grid.dart';

void main() {
  late List<GroupEntity> groups;

  setUp(() {
    groups = [
      GroupEntity(id: '1', name: 'Electronics'),
      GroupEntity(id: '2', name: 'Clothing'),
      GroupEntity(id: '3', name: 'Books'),
      GroupEntity(id: '4', name: 'Furniture'),
    ];
  });

  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: SizedBox(height: 600, child: child)),
    );
  }

  testWidgets('should display all groups', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(GroupGrid(groups: groups, shrinkWrap: true)),
    );

    for (final group in groups) {
      expect(find.text(group.name), findsOneWidget);
    }
  });

  testWidgets('should support custom crossAxisCount', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(GroupGrid(groups: groups, crossAxisCount: 3)),
    );

    final grid = tester.widget<GridView>(find.byType(GridView));

    final delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

    expect(delegate.crossAxisCount, 3);
  });

  testWidgets('should call onGroupTap with the selected group', (tester) async {
    GroupEntity? selectedGroup;

    await tester.pumpWidget(
      buildTestWidget(
        GroupGrid(
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
        GroupGrid(
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
  });

  testWidgets('should render empty grid when groups are empty', (tester) async {
    await tester.pumpWidget(buildTestWidget(const GroupGrid(groups: [])));

    expect(find.byType(GridView), findsOneWidget);
  });
}
