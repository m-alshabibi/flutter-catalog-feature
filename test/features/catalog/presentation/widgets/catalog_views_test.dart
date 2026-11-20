import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/result/result.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/widgets/groups/groups_view.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/widgets/catalog_items/group_catalog_view.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/widgets/favorites/favorites_view.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/widgets/favorites/favorite_button.dart';
import '../../../../support/cubit_factories.dart';
import '../../../../support/fake_repositories.dart';
import '../../../../support/fixtures.dart';

void main() {
  testWidgets('GroupsView renders groups from CatalogCubit', (tester) async {
    final repository = FakeGroupRepository()..groupsResult = Success([makeGroup()]);
    final cubit = createCatalogCubit(groups: repository);
    await cubit.loadCatalog();
    await tester.pumpWidget(MaterialApp(
      home: BlocProvider.value(
        value: cubit,
        child: const Scaffold(body: GroupsView()),
      ),
    ));
    expect(find.text('Group One'), findsOneWidget);
    await cubit.close();
  });

  testWidgets('GroupCatalogView loads and displays items for its group', (tester) async {
    final groupRepository = FakeGroupRepository()..groupsResult = Success([makeGroup()]);
    final itemRepository = FakeCatalogItemRepository()
      ..itemsResult = Success([makeItem(imageUrl: null)]);
    final cubit = createCatalogCubit(groups: groupRepository, items: itemRepository);
    await cubit.loadCatalog();
    await tester.pumpWidget(MaterialApp(
      home: BlocProvider.value(
        value: cubit,
        child: const Scaffold(body: GroupCatalogView(groupId: 'group-1')),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Item One'), findsOneWidget);
    await cubit.close();
  });

  testWidgets('FavoritesView renders favorites from FavoritesCubit', (tester) async {
    final favoriteRepository = FakeFavoriteRepository()
      ..favoritesResult = Success([makeFavorite()]);
    final itemRepository = FakeCatalogItemRepository()
      ..itemsByIdsResult = Success([makeItem(imageUrl: null)]);
    final cubit = createFavoritesCubit(favorites: favoriteRepository, items: itemRepository);
    await cubit.loadFavorites();
    await tester.pumpWidget(MaterialApp(
      home: BlocProvider.value(
        value: cubit,
        child: const Scaffold(body: FavoritesView()),
      ),
    ));
    expect(find.text('Item One'), findsOneWidget);
    await cubit.close();
  });

  testWidgets('FavoriteButton toggles an existing favorite off', (tester) async {
    final favoriteRepository = FakeFavoriteRepository()
      ..favoritesResult = Success([makeFavorite()]);
    final itemRepository = FakeCatalogItemRepository()
      ..itemsByIdsResult = Success([makeItem(imageUrl: null)]);
    final cubit = createFavoritesCubit(favorites: favoriteRepository, items: itemRepository);
    await cubit.loadFavorites();

    await tester.pumpWidget(MaterialApp(
      home: BlocProvider.value(
        value: cubit,
        child: const Scaffold(body: FavoriteButton(itemId: 'item-1')),
      ),
    ));
    expect(find.byTooltip('Remove from favorites'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove from favorites'));
    await tester.pumpAndSettle();
    expect(favoriteRepository.removeCalls, 1);
    expect(find.byTooltip('Add to favorites'), findsOneWidget);
    await cubit.close();
  });
}
