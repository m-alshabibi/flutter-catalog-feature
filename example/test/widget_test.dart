import 'package:flutter/material.dart';
import 'package:flutter_catalog_feature/features/catalog/di/injection_container.dart';
import 'package:flutter_catalog_feature_example/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

void main() {
  final getIt = GetIt.instance;

  setUp(() async {
    await getIt.reset();

    initCatalogDependencies(getIt: getIt, baseUrl: 'http://localhost:8000');
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('DemoApp displays the main navigation', (tester) async {
    await tester.pumpWidget(DemoApp(getIt: getIt, userId: 'test-user'));

    await tester.pump();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Catalog'), findsWidgets);
    expect(find.text('Favorites'), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
