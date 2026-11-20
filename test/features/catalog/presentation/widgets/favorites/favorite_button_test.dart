import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/favorites/favorites_cubit.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/favorites/favorites_state.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/widgets/favorites/favorite_button.dart';
import 'package:mocktail/mocktail.dart';

class MockFavoritesCubit extends Mock implements FavoritesCubit {}

void main() {
  late MockFavoritesCubit mockFavoritesCubit;

  const itemId = 'item-1';

  Widget buildSubject({Widget button = const FavoriteButton(itemId: itemId)}) {
    return MaterialApp(
      home: BlocProvider<FavoritesCubit>.value(
        value: mockFavoritesCubit,
        child: Scaffold(body: Center(child: button)),
      ),
    );
  }

  setUp(() {
    mockFavoritesCubit = MockFavoritesCubit();

    when(() => mockFavoritesCubit.state).thenReturn(FavoritesState());

    when(() => mockFavoritesCubit.stream)
        .thenAnswer((_) => const Stream.empty());

    when(() => mockFavoritesCubit.toggleFavorite(any()))
        .thenAnswer((_) async {});
  });

  group('FavoriteButton', () {
    testWidgets('should display favorite border when item is not favorite', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('should display filled favorite when item is favorite', (
      tester,
    ) async {
      when(() => mockFavoritesCubit.state)
          .thenReturn(FavoritesState(favoriteItemIds: {itemId}));

      await tester.pumpWidget(buildSubject());

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('should show loading indicator when item is updating', (
      tester,
    ) async {
      when(() => mockFavoritesCubit.state)
          .thenReturn(FavoritesState(updatingItemIds: {itemId}));

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should disable button while item is updating', (tester) async {
      when(() => mockFavoritesCubit.state)
          .thenReturn(FavoritesState(updatingItemIds: {itemId}));

      await tester.pumpWidget(buildSubject());

      final button = tester.widget<IconButton>(find.byType(IconButton));

      expect(button.onPressed, isNull);
    });

    testWidgets('should toggle favorite when pressed', (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.tap(find.byType(IconButton));

      verify(() => mockFavoritesCubit.toggleFavorite(itemId)).called(1);
    });

    testWidgets('should use custom builder when provided', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          button: const FavoriteButton(itemId: itemId, builder: _customBuilder),
        ),
      );

      expect(find.text('Custom favorite button'), findsOneWidget);
    });
  });
}

Widget _customBuilder(
  BuildContext context,
  bool isFavorite,
  bool isUpdating,
  VoidCallback onPressed,
) {
  return TextButton(
    onPressed: isUpdating ? null : onPressed,
    child: const Text('Custom favorite button'),
  );
}
