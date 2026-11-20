import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/result/result.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/get_catalog_item_by_id_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/catalog_item_details/catalog_item_details_cubit.dart';
import '../../../../support/fake_repositories.dart';
import '../../../../support/fixtures.dart';

void main() {
  test('loads the requested catalog item', () async {
    final repository = FakeCatalogItemRepository()..itemResult = Success(makeItem());
    final cubit = CatalogItemDetailsCubit(
      getCatalogItemByIdUseCase: GetCatalogItemByIdUseCase(repository),
      itemId: 'item-1',
    );
    await cubit.loadItem();
    expect(cubit.state.item!.id, 'item-1');
    expect(cubit.state.hasLoaded, isTrue);
    await cubit.close();
  });

  test('rejects an empty item ID', () {
    final repository = FakeCatalogItemRepository();
    expect(
      () => CatalogItemDetailsCubit(
        getCatalogItemByIdUseCase: GetCatalogItemByIdUseCase(repository),
        itemId: ' ',
      ),
      throwsArgumentError,
    );
  });
}
