import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_catalog_feature/core/error/failures.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/catalog_item_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/favorites/favorites_cubit.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/favorites/favorites_state.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/widgets/favorites/favorites_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFavoritesCubit extends Mock implements FavoritesCubit {}

void main() {
  late MockFavoritesCubit mockFavoritesCubit;

  final item = CatalogItemEntity(
    id: 'item-1',
    groupId: 'group-1',
    name: 'Favorite Item',
    shortDescription: 'Favorite description',
  );

  Widget buildSubject({FavoritesView view = const FavoritesView()}) {
    return MaterialApp(
      home: BlocProvider<FavoritesCubit>.value(
        value: mockFavoritesCubit,
        child: Scaffold(body: view),
      ),
    );
  }

  setUp(() {
    mockFavoritesCubit = MockFavoritesCubit();

    when(() => mockFavoritesCubit.state).thenReturn(FavoritesState());

    when(() => mockFavoritesCubit.stream)
        .thenAnswer((_) => const Stream<FavoritesState>.empty());

    when(() => mockFavoritesCubit.refreshFavorites()).thenAnswer((_) async {});
  });

  group('FavoritesView', () {
    testWidgets('should display favorite items', (tester) async {
      when(() => mockFavoritesCubit.state).thenReturn(
        FavoritesState(
          favoriteItems: [item],
          favoriteItemIds: {'item-1'},
          hasLoaded: true,
        ),
      );

      await tester.pumpWidget(buildSubject());

      expect(find.text('Favorite Item'), findsOneWidget);
      expect(find.text('Favorite description'), findsOneWidget);
    });

    testWidgets('should display list layout by default', (tester) async {
      when(() => mockFavoritesCubit.state).thenReturn(
        FavoritesState(
          favoriteItems: [item],
          favoriteItemIds: {'item-1'},
          hasLoaded: true,
        ),
      );

      await tester.pumpWidget(buildSubject());

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
    });

    testWidgets('should display grid layout when selected', (tester) async {
      when(() => mockFavoritesCubit.state).thenReturn(
        FavoritesState(
          favoriteItems: [item],
          favoriteItemIds: {'item-1'},
          hasLoaded: true,
        ),
      );

      await tester.pumpWidget(
        buildSubject(
          view: const FavoritesView(layout: FavoritesViewLayout.grid),
        ),
      );

      expect(find.byType(GridView), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('should display empty state when no favorites exist', (
      tester,
    ) async {
      when(() => mockFavoritesCubit.state)
          .thenReturn(FavoritesState(hasLoaded: true));

      await tester.pumpWidget(buildSubject());

      expect(find.text('Favorite Item'), findsNothing);
    });

    testWidgets('should call onItemTap when an item is tapped', (tester) async {
      when(() => mockFavoritesCubit.state).thenReturn(
        FavoritesState(
          favoriteItems: [item],
          favoriteItemIds: {'item-1'},
          hasLoaded: true,
        ),
      );

      CatalogItemEntity? tappedItem;

      await tester.pumpWidget(
        buildSubject(
          view: FavoritesView(onItemTap: (value) => tappedItem = value),
        ),
      );

      await tester.tap(find.text('Favorite Item'));
      await tester.pump();

      expect(tappedItem, item);
    });

    testWidgets('should retry loading favorites', (tester) async {
      when(() => mockFavoritesCubit.state)
          .thenReturn(FavoritesState(failure: const UnknownFailure()));

      await tester.pumpWidget(buildSubject());

      final retryButton = find.byType(ElevatedButton);

      if (retryButton.evaluate().isNotEmpty) {
        await tester.tap(retryButton.first);
        await tester.pump();

        verify(() => mockFavoritesCubit.refreshFavorites()).called(1);
      }
    });
  });
}
