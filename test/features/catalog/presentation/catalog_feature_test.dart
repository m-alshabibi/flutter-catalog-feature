import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/catalog_feature.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/catalog/catalog_cubit.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/favorites/favorites_cubit.dart';
import '../../../support/cubit_factories.dart';

void main() {
  testWidgets('provides the catalog and user-scoped favorites cubits', (tester) async {
    final locator = GetIt.asNewInstance();
    locator.registerFactory<CatalogCubit>(() => createCatalogCubit());
    locator.registerFactoryParam<FavoritesCubit, String, void>(
      (userId, _) => createFavoritesCubit(userId: userId),
    );

    await tester.pumpWidget(MaterialApp(
      home: CatalogFeature(
        getIt: locator,
        userId: 'user-42',
        child: Builder(
          builder: (context) {
            final catalog = context.watch<CatalogCubit>();
            final favorites = context.watch<FavoritesCubit>();
            return Text('${favorites.userId}:${catalog.state.groups.length}');
          },
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('user-42:0'), findsOneWidget);
    await locator.reset();
  });
}
