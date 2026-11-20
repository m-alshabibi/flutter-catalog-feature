import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/catalog_item_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/group_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/catalog/catalog_cubit.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/catalog/catalog_state.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/pages/group_catalog_page.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/widgets/catalog_items/group_catalog_view.dart';
import 'package:mocktail/mocktail.dart';

class MockCatalogCubit extends Mock implements CatalogCubit {}

class MockGroupEntity extends Mock implements GroupEntity {}

void main() {
  late MockCatalogCubit catalogCubit;
  late MockGroupEntity group;

  setUp(() {
    catalogCubit = MockCatalogCubit();
    group = MockGroupEntity();

    when(() => catalogCubit.state).thenReturn(CatalogState());

    when(() => catalogCubit.stream).thenAnswer((_) => const Stream.empty());

    when(
      () => catalogCubit.loadGroupItems(
        any(),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async {});

    when(() => catalogCubit.retryLoadGroupItems(any()))
        .thenAnswer((_) async {});

    when(() => group.id).thenReturn('group-1');
    when(() => group.name).thenReturn('Group One');
  });

  // tearDown(() async {
  //   await catalogCubit.close();
  // });

  Widget buildSubject({ValueChanged<CatalogItemEntity>? onItemTap}) {
    return MaterialApp(
      home: BlocProvider<CatalogCubit>.value(
        value: catalogCubit,
        child: GroupCatalogPage(group: group, onItemTap: onItemTap ?? (_) {}),
      ),
    );
  }

  testWidgets('should display group name in app bar', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('Group One'), findsOneWidget);
  });

  testWidgets('should display GroupCatalogView', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.byType(GroupCatalogView), findsOneWidget);
  });

  testWidgets('should load items using the selected group ID', (tester) async {
    await tester.pumpWidget(buildSubject());

    verify(
      () => catalogCubit.loadGroupItems(
        'group-1',
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).called(1);
  });
}
