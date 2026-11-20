import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_catalog_feature/features/catalog/data/datasources/local/database/app_database.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/repositories/catalog_item_repository.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/repositories/favorite_repository.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/repositories/group_repository.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/get_all_catalog_items_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/get_catalog_items_with_favorite_status_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/get_favorites_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/get_groups_with_catalog_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/refresh_catalog_items_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/catalog/catalog_cubit.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/catalog_item_details/catalog_item_details_cubit.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/favorites/favorites_cubit.dart';
import 'package:flutter_catalog_feature/features/catalog/di/injection_container.dart';

void main() {
  test('registers feature repositories, database and presentation factories', () async {
    final locator = GetIt.asNewInstance();
    initCatalogDependencies(getIt: locator, baseUrl: 'https://api.example.test');

    expect(locator.isRegistered<AppDatabase>(), isTrue);
    expect(locator.isRegistered<GroupRepository>(), isTrue);
    expect(locator.isRegistered<CatalogItemRepository>(), isTrue);
    expect(locator.isRegistered<FavoriteRepository>(), isTrue);
    expect(locator.isRegistered<CatalogCubit>(), isTrue);
    expect(locator.isRegistered<FavoritesCubit>(), isTrue);
    expect(locator.isRegistered<CatalogItemDetailsCubit>(), isTrue);

    expect(locator.isRegistered<GetAllCatalogItemsUseCase>(), isFalse);
    expect(locator.isRegistered<GetCatalogItemsWithFavoriteStatusUseCase>(), isFalse);
    expect(locator.isRegistered<GetFavoritesUseCase>(), isFalse);
    expect(locator.isRegistered<GetGroupsWithCatalogUseCase>(), isFalse);
    expect(locator.isRegistered<RefreshCatalogItemsUseCase>(), isFalse);

    await locator.reset();
  });
}
