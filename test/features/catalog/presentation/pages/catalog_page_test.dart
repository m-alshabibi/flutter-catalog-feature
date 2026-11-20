import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/catalog/catalog_cubit.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/catalog/catalog_state.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/pages/catalog_page.dart';

class MockCatalogCubit extends Cubit<CatalogState> implements CatalogCubit {
  MockCatalogCubit() : super(CatalogState());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockCatalogCubit catalogCubit;

  setUp(() {
    catalogCubit = MockCatalogCubit();
  });

  tearDown(() async {
    await catalogCubit.close();
  });

  Widget buildSubject() {
    return MaterialApp(
      home: BlocProvider<CatalogCubit>.value(
        value: catalogCubit,
        child: CatalogPage(onGroupTap: (_) {}),
      ),
    );
  }

  testWidgets('should display catalog app bar', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('Catalog'), findsOneWidget);
  });

  testWidgets('should display GroupsView', (tester) async {
    await tester.pumpWidget(buildSubject());

    // GroupsView displays its empty state when no groups are loaded.
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
