import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/group_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/catalog/catalog_cubit.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/catalog/catalog_state.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/widgets/groups/groups_view.dart';
import 'package:mocktail/mocktail.dart';

class MockCatalogCubit extends Mock implements CatalogCubit {}

void main() {
  late MockCatalogCubit catalogCubit;

  final groups = [
    GroupEntity(id: 'group-1', name: 'Electronics'),
    GroupEntity(id: 'group-2', name: 'Clothing'),
  ];

  Widget buildTestWidget(
    CatalogState state, {
    GroupsViewLayout layout = GroupsViewLayout.list,
    ValueChanged<GroupEntity>? onGroupTap,
  }) {
    catalogCubit = MockCatalogCubit();

    when(() => catalogCubit.state).thenReturn(state);
    when(() => catalogCubit.stream)
        .thenAnswer((_) => const Stream<CatalogState>.empty());

    when(() => catalogCubit.retryLoadGroups()).thenAnswer((_) async {});

    return MaterialApp(
      home: BlocProvider<CatalogCubit>.value(
        value: catalogCubit,
        child: Scaffold(
          body: SizedBox(
            height: 600,
            child: GroupsView(layout: layout, onGroupTap: onGroupTap),
          ),
        ),
      ),
    );
  }

  testWidgets('should display groups using list layout', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(CatalogState(groups: groups, hasLoaded: true)),
    );

    expect(find.text('Electronics'), findsOneWidget);
    expect(find.text('Clothing'), findsOneWidget);
  });

  testWidgets('should display groups using grid layout', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        CatalogState(groups: groups, hasLoaded: true),
        layout: GroupsViewLayout.grid,
      ),
    );

    expect(find.byType(GridView), findsOneWidget);
    expect(find.text('Electronics'), findsOneWidget);
    expect(find.text('Clothing'), findsOneWidget);
  });

  testWidgets('should display loading view during initial loading', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestWidget(CatalogState(isLoading: true)));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('should display empty view when no groups are available', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(CatalogState(groups: const [], hasLoaded: true)),
    );

    expect(find.text('No items found.'), findsOneWidget);
  });

  testWidgets('should call onGroupTap with selected group', (tester) async {
    GroupEntity? selectedGroup;

    await tester.pumpWidget(
      buildTestWidget(
        CatalogState(groups: groups, hasLoaded: true),
        onGroupTap: (group) => selectedGroup = group,
      ),
    );

    await tester.tap(find.text('Clothing'));

    expect(selectedGroup, same(groups[1]));
  });

  testWidgets('should keep existing groups visible while refreshing', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(
        CatalogState(groups: groups, hasLoaded: true, isRefreshing: true),
      ),
    );

    expect(find.text('Electronics'), findsOneWidget);
    expect(find.text('Clothing'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
