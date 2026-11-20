import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_catalog_feature/core/result/result.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/catalog_item_details/catalog_item_details_cubit.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/favorites/favorites_cubit.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/pages/catalog_item_details_page.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/pages/catalog_page.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/pages/favorites_page.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/pages/group_catalog_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../../../support/cubit_factories.dart';
import '../../../../support/fake_repositories.dart';
import '../../../../support/fixtures.dart';

void main() {
  testWidgets('CatalogPage renders catalog groups', (tester) async {
    final groups = FakeGroupRepository()..groupsResult = Success([makeGroup()]);
    final cubit = createCatalogCubit(groups: groups);
    await cubit.loadCatalog();
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: CatalogPage(onGroupTap: (_) {}),
        ),
      ),
    );
    expect(find.text('Catalog'), findsOneWidget);
    expect(find.text('Group One'), findsOneWidget);
    await cubit.close();
  });

  testWidgets('GroupCatalogPage renders its group title and items', (
    tester,
  ) async {
    final groups = FakeGroupRepository()..groupsResult = Success([makeGroup()]);
    final items = FakeCatalogItemRepository()
      ..itemsResult = Success([makeItem(imageUrl: null)]);
    final cubit = createCatalogCubit(groups: groups, items: items);
    await cubit.loadCatalog();
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: GroupCatalogPage(group: makeGroup(), onItemTap: (_) {}),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Group One'), findsOneWidget);
    expect(find.text('Item One'), findsOneWidget);
    await cubit.close();
  });

  testWidgets('FavoritesPage renders the user\'s favorites', (tester) async {
    final favoriteRepo = FakeFavoriteRepository()
      ..favoritesResult = Success([makeFavorite()]);
    final itemRepo = FakeCatalogItemRepository()
      ..itemsByIdsResult = Success([makeItem(imageUrl: null)]);
    final cubit = createFavoritesCubit(
      favorites: favoriteRepo,
      items: itemRepo,
    );
    await cubit.loadFavorites();
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: FavoritesPage(onItemTap: (_) {}),
        ),
      ),
    );
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Item One'), findsOneWidget);
    await cubit.close();
  });

  testWidgets(
    "CatalogItemDetailsPage creates its detail cubit using the item ID",
    (tester) async {
      final locator = GetIt.asNewInstance();
      final itemRepo = FakeCatalogItemRepository()
        ..itemResult = Success(makeItem(imageUrl: null, gallery: const []));
      final detailCubit = createDetailsCubit(itemId: 'item-1', items: itemRepo);
      locator.registerFactoryParam<CatalogItemDetailsCubit, String, void>(
        (id, _) => detailCubit,
      );
      final favoritesCubit = createFavoritesCubit();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<FavoritesCubit>.value(
            value: favoritesCubit,
            child: CatalogItemDetailsPage(
              getIt: locator,
              itemId: 'item-1',
              onOpenItem: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Item Details'), findsOneWidget);
      expect(find.text('Item One'), findsOneWidget);

      await locator.reset();
      await favoritesCubit.close();
    },
  );
}
