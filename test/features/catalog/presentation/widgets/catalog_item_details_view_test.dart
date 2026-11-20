import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/result/result.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/catalog_item_details/catalog_item_details_cubit.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/favorites/favorites_cubit.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/widgets/catalog_item_details/catalog_item_details_view.dart';
import '../../../../support/cubit_factories.dart';
import '../../../../support/fake_repositories.dart';
import '../../../../support/fixtures.dart';

void main() {
  testWidgets('loads and displays catalog item details', (tester) async {
    final itemRepository = FakeCatalogItemRepository()..itemResult = Success(makeItem(imageUrl: null));
    final detailsCubit = createDetailsCubit(items: itemRepository);
    final favoritesCubit = createFavoritesCubit();

    await tester.pumpWidget(MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<CatalogItemDetailsCubit>.value(value: detailsCubit),
          BlocProvider<FavoritesCubit>.value(value: favoritesCubit),
        ],
        child: const Scaffold(body: CatalogItemDetailsView()),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Item One'), findsOneWidget);
    expect(find.text('Long description'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);

    await detailsCubit.close();
    await favoritesCubit.close();
  });

  testWidgets('calls the host callback when Open item is pressed', (tester) async {
    final item = makeItem(imageUrl: null, gallery: const []);
    final itemRepository = FakeCatalogItemRepository()..itemResult = Success(item);
    final detailsCubit = createDetailsCubit(items: itemRepository);
    final favoritesCubit = createFavoritesCubit();
    String? openedId;

    await tester.pumpWidget(MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<CatalogItemDetailsCubit>.value(value: detailsCubit),
          BlocProvider<FavoritesCubit>.value(value: favoritesCubit),
        ],
        child: Scaffold(body: CatalogItemDetailsView(onOpenItem: (value) => openedId = value.id)),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open item'));
    expect(openedId, 'item-1');

    await detailsCubit.close();
    await favoritesCubit.close();
  });
}
