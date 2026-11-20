import 'package:flutter/material.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/catalog_item_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/catalog_item_details/catalog_item_details_cubit.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/catalog_item_details/catalog_item_details_state.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/pages/catalog_item_details_page.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/widgets/catalog_item_details/catalog_item_details_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

class MockCatalogItemDetailsCubit extends Mock
    implements CatalogItemDetailsCubit {}

class MockCatalogItemEntity extends Mock implements CatalogItemEntity {}

void main() {
  late GetIt getIt;
  late MockCatalogItemDetailsCubit detailsCubit;
  late MockCatalogItemEntity item;

  const itemId = 'item-1';

  setUp(() {
    getIt = GetIt.asNewInstance();

    detailsCubit = MockCatalogItemDetailsCubit();
    item = MockCatalogItemEntity();

    when(() => item.id).thenReturn(itemId);
    when(() => item.name).thenReturn('Test Item');
    when(() => item.groupId).thenReturn('group-1');
    when(() => item.gallery).thenReturn(<String>[]);
    when(() => detailsCubit.state)
        .thenReturn(CatalogItemDetailsState(item: item, hasLoaded: true));

    when(() => detailsCubit.stream).thenAnswer((_) => const Stream.empty());

    when(() => detailsCubit.loadItem()).thenAnswer((_) async {});

    when(() => detailsCubit.retryLoadItem()).thenAnswer((_) async {});

    when(() => detailsCubit.close()).thenAnswer((_) async {});

    getIt.registerFactoryParam<CatalogItemDetailsCubit, String, void>(
      (param1, _) => detailsCubit,
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget buildSubject({ValueChanged<CatalogItemEntity>? onOpenItem}) {
    return MaterialApp(
      home: CatalogItemDetailsPage(
        getIt: getIt,
        itemId: itemId,
        onOpenItem: onOpenItem ?? (_) {},
      ),
    );
  }

  testWidgets('should display item details app bar', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('Item Details'), findsOneWidget);
  });

  testWidgets('should display CatalogItemDetailsView', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.byType(CatalogItemDetailsView), findsOneWidget);
  });

  testWidgets('should create details cubit using the item ID', (tester) async {
    String? receivedItemId;

    await getIt.reset();

    getIt.registerFactoryParam<CatalogItemDetailsCubit, String, void>((
      param1,
      _,
    ) {
      receivedItemId = param1;
      return detailsCubit;
    });

    await tester.pumpWidget(buildSubject());

    expect(receivedItemId, itemId);
  });
}
