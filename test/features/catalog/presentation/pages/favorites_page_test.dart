import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/catalog_item_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/favorites/favorites_cubit.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/favorites/favorites_state.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/pages/favorites_page.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/widgets/favorites/favorites_view.dart';
import 'package:mocktail/mocktail.dart';

class MockFavoritesCubit extends Mock implements FavoritesCubit {}

void main() {
  late MockFavoritesCubit favoritesCubit;

  setUp(() {
    favoritesCubit = MockFavoritesCubit();

    when(() => favoritesCubit.state).thenReturn(FavoritesState());
    when(() => favoritesCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => favoritesCubit.loadFavorites()).thenAnswer((_) async {});
  });

  Widget buildSubject({required ValueChanged<CatalogItemEntity> onItemTap}) {
    return MaterialApp(
      home: BlocProvider<FavoritesCubit>.value(
        value: favoritesCubit,
        child: FavoritesPage(onItemTap: onItemTap),
      ),
    );
  }

  group('FavoritesPage', () {
    testWidgets('should display favorites app bar', (tester) async {
      await tester.pumpWidget(buildSubject(onItemTap: (_) {}));

      expect(find.text('Favorites'), findsOneWidget);
    });

    testWidgets('should display FavoritesView', (tester) async {
      await tester.pumpWidget(buildSubject(onItemTap: (_) {}));

      expect(find.byType(FavoritesView), findsOneWidget);
    });

    testWidgets('should pass onItemTap callback to FavoritesView', (
      tester,
    ) async {
      void onItemTap(CatalogItemEntity item) {}

      await tester.pumpWidget(buildSubject(onItemTap: onItemTap));

      final favoritesView = tester.widget<FavoritesView>(
        find.byType(FavoritesView),
      );

      expect(favoritesView.onItemTap, same(onItemTap));
    });
  });
}
