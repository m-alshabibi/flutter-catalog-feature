import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/catalog_item_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/catalog/catalog_cubit.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/catalog/catalog_state.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/catalog/group_catalog_state.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/widgets/catalog_items/catalog_item_grid.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/widgets/catalog_items/catalog_item_list.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/widgets/catalog_items/group_catalog_view.dart';
import 'package:mocktail/mocktail.dart';

class MockCatalogCubit extends Mock implements CatalogCubit {}

void main() {
  late MockCatalogCubit catalogCubit;

  final item = CatalogItemEntity(
    id: 'item-1',
    groupId: 'group-1',
    name: 'Test Item',
    shortDescription: 'Test description',
  );

  Widget buildTestWidget({
    String groupId = 'group-1',
    GroupCatalogViewLayout layout = GroupCatalogViewLayout.list,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<CatalogCubit>.value(
          value: catalogCubit,
          child: GroupCatalogView(groupId: groupId, layout: layout),
        ),
      ),
    );
  }

  setUp(() {
    catalogCubit = MockCatalogCubit();
  });

  void stubCubit(CatalogState state) {
    when(() => catalogCubit.state).thenReturn(state);

    when(() => catalogCubit.stream)
        .thenAnswer((_) => const Stream<CatalogState>.empty());

    when(() => catalogCubit.loadGroupItems('group-1')).thenAnswer((_) async {});

    when(() => catalogCubit.loadGroupItems('group-2')).thenAnswer((_) async {});

    when(() => catalogCubit.retryLoadGroupItems('group-1'))
        .thenAnswer((_) async {});

    when(() => catalogCubit.retryLoadGroupItems('group-2'))
        .thenAnswer((_) async {});
  }

  group('GroupCatalogView', () {
    testWidgets('should load group items when initialized', (tester) async {
      stubCubit(CatalogState());

      await tester.pumpWidget(buildTestWidget());

      verify(() => catalogCubit.loadGroupItems('group-1')).called(1);
    });

    testWidgets('should display group items', (tester) async {
      stubCubit(
        CatalogState(
          catalogByGroupId: {
            'group-1': GroupCatalogState(items: [item], hasLoaded: true),
          },
        ),
      );

      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Test Item'), findsOneWidget);
      expect(find.text('Test description'), findsOneWidget);
    });

    testWidgets('should display list layout by default', (tester) async {
      stubCubit(
        CatalogState(
          catalogByGroupId: {
            'group-1': GroupCatalogState(items: [item], hasLoaded: true),
          },
        ),
      );

      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(CatalogItemList), findsOneWidget);
    });

    testWidgets('should display grid layout when selected', (tester) async {
      stubCubit(
        CatalogState(
          catalogByGroupId: {
            'group-1': GroupCatalogState(items: [item], hasLoaded: true),
          },
        ),
      );

      await tester.pumpWidget(
        buildTestWidget(layout: GroupCatalogViewLayout.grid),
      );

      expect(find.byType(CatalogItemGrid), findsOneWidget);
    });

    testWidgets('should load items when groupId changes', (tester) async {
      stubCubit(CatalogState());

      await tester.pumpWidget(buildTestWidget());

      await tester.pumpWidget(buildTestWidget(groupId: 'group-2'));

      verify(() => catalogCubit.loadGroupItems('group-1')).called(1);
      verify(() => catalogCubit.loadGroupItems('group-2')).called(1);
    });
  });
}
