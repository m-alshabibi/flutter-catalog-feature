import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/network_info.dart';
import '../data/datasources/local/catalog_item_local_data_source.dart';
import '../data/datasources/local/database/app_database.dart';
import '../data/datasources/local/favorite_local_data_source.dart';
import '../data/datasources/local/group_local_data_source.dart';
import '../data/datasources/remote/catalog_item_remote_data_source.dart';
import '../data/datasources/remote/favorite_remote_data_source.dart';
import '../data/datasources/remote/group_remote_data_source.dart';
import '../data/repositories/catalog_item_repository_impl.dart';
import '../data/repositories/favorite_repository_impl.dart';
import '../data/repositories/group_repository_impl.dart';
import '../domain/repositories/catalog_item_repository.dart';
import '../domain/repositories/favorite_repository.dart';
import '../domain/repositories/group_repository.dart';
import '../domain/usecases/add_favorite_use_case.dart';
// import '../domain/usecases/get_all_catalog_items_use_case.dart';
import '../domain/usecases/get_catalog_item_by_id_use_case.dart';
import '../domain/usecases/get_catalog_items_use_case.dart';
// import '../domain/usecases/get_catalog_items_with_favorite_status_use_case.dart';
import '../domain/usecases/get_favorite_catalog_items_use_case.dart';
// import '../domain/usecases/get_favorites_use_case.dart';
import '../domain/usecases/get_groups_use_case.dart';
// import '../domain/usecases/get_groups_with_catalog_use_case.dart';
import '../domain/usecases/refresh_catalog_items_by_group_use_case.dart';
// import '../domain/usecases/refresh_catalog_items_use_case.dart';
import '../domain/usecases/refresh_favorites_use_case.dart';
import '../domain/usecases/refresh_groups_use_case.dart';
import '../domain/usecases/remove_favorite_use_case.dart';
import '../presentation/controllers/catalog/catalog_cubit.dart';
import '../presentation/controllers/catalog_item_details/catalog_item_details_cubit.dart';
import '../presentation/controllers/favorites/favorites_cubit.dart';

/// Registers all dependencies required by the Catalog feature.
///
/// The host application provides the GetIt instance and API base URL.
///
/// [baseUrl] is the root API endpoint used to configure DioClient,
/// allowing the host application to switch between environments.
void initCatalogDependencies({required GetIt getIt, required String baseUrl}) {
  _registerCoreDependencies(getIt: getIt, baseUrl: baseUrl);

  _registerDatabase(getIt);

  _registerLocalDataSources(getIt);

  _registerRemoteDataSources(getIt);

  _registerRepositories(getIt);

  _registerUseCases(getIt);

  _registerPresentation(getIt);
}

void _registerCoreDependencies({
  required GetIt getIt,
  required String baseUrl,
}) {
  // Register the configured Dio client only if it does not exist.
  _registerLazySingletonIfAbsent<DioClient>(
    getIt: getIt,
    factory: () => DioClient(baseUrl: baseUrl),
  );

  // Reuse an existing Dio instance if the host application provided one.
  _registerLazySingletonIfAbsent<Dio>(
    getIt: getIt,
    factory: () => getIt<DioClient>().dio,
  );

  // Register connectivity only once.
  _registerLazySingletonIfAbsent<Connectivity>(
    getIt: getIt,
    factory: () => Connectivity(),
  );

  // Reuse an existing NetworkInfo implementation if available.
  _registerLazySingletonIfAbsent<NetworkInfo>(
    getIt: getIt,
    factory: () => NetworkInfoImpl(getIt<Connectivity>()),
  );
}

/// Registers the local database used by the Catalog feature.
void _registerDatabase(GetIt getIt) {
  // One database instance is shared by all local data sources.
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());
}

/// Registers all local data sources.
void _registerLocalDataSources(GetIt getIt) {
  getIt.registerLazySingleton<GroupLocalDataSource>(
    () => GroupLocalDataSourceImpl(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<CatalogItemLocalDataSource>(
    () => CatalogItemLocalDataSourceImpl(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<FavoriteLocalDataSource>(
    () => FavoriteLocalDataSourceImpl(getIt<AppDatabase>()),
  );
}

/// Registers all remote data sources.
void _registerRemoteDataSources(GetIt getIt) {
  getIt.registerLazySingleton<GroupRemoteDataSource>(
    () => GroupRemoteDataSourceImpl(getIt<Dio>()),
  );

  getIt.registerLazySingleton<CatalogItemRemoteDataSource>(
    () => CatalogItemRemoteDataSourceImpl(getIt<Dio>()),
  );

  getIt.registerLazySingleton<FavoriteRemoteDataSource>(
    () => FavoriteRemoteDataSourceImpl(getIt<Dio>()),
  );
}

/// Registers repository implementations against their domain contracts.
///
/// Domain layers depend only on repository abstractions,
/// while the DI container provides their concrete implementations.
void _registerRepositories(GetIt getIt) {
  getIt.registerLazySingleton<GroupRepository>(
    () => GroupRepositoryImpl(
      localDataSource: getIt<GroupLocalDataSource>(),
      remoteDataSource: getIt<GroupRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<CatalogItemRepository>(
    () => CatalogItemRepositoryImpl(
      localDataSource: getIt<CatalogItemLocalDataSource>(),
      remoteDataSource: getIt<CatalogItemRemoteDataSource>(),
      groupLocalDataSource: getIt<GroupLocalDataSource>(),
      groupRepository: getIt<GroupRepository>(),
    ),
  );

  getIt.registerLazySingleton<FavoriteRepository>(
    () => FavoriteRepositoryImpl(
      localDataSource: getIt<FavoriteLocalDataSource>(),
      remoteDataSource: getIt<FavoriteRemoteDataSource>(),
      catalogItemRepository: getIt<CatalogItemRepository>(),
    ),
  );
}

/// Registers all use cases provided by the Catalog feature.
///
/// Use cases are stateless and depend on repository abstractions.
/// They are registered as lazy singletons to reuse their instances.
void _registerUseCases(GetIt getIt) {
  // ---------------------------------------------------------------------------
  // Group Use Cases
  // ---------------------------------------------------------------------------

  getIt.registerLazySingleton<GetGroupsUseCase>(
    () => GetGroupsUseCase(getIt<GroupRepository>()),
  );

  getIt.registerLazySingleton<RefreshGroupsUseCase>(
    () => RefreshGroupsUseCase(getIt<GroupRepository>()),
  );

  // ---------------------------------------------------------------------------
  // Catalog Item Use Cases
  // ---------------------------------------------------------------------------

  // Currently unused: no Presentation consumer is registered.
  //   getIt.registerLazySingleton<GetAllCatalogItemsUseCase>(
  //     () => GetAllCatalogItemsUseCase(getIt<CatalogItemRepository>()),
  //   );

  getIt.registerLazySingleton<GetCatalogItemsUseCase>(
    () => GetCatalogItemsUseCase(getIt<CatalogItemRepository>()),
  );

  getIt.registerLazySingleton<GetCatalogItemByIdUseCase>(
    () => GetCatalogItemByIdUseCase(getIt<CatalogItemRepository>()),
  );

  // Currently unused: no Presentation consumer is registered.
  //   getIt.registerLazySingleton<RefreshCatalogItemsUseCase>(
  //     () => RefreshCatalogItemsUseCase(getIt<CatalogItemRepository>()),
  //   );

  getIt.registerLazySingleton<RefreshCatalogItemsByGroupUseCase>(
    () => RefreshCatalogItemsByGroupUseCase(getIt<CatalogItemRepository>()),
  );

  // ---------------------------------------------------------------------------
  // Favorite Use Cases
  // ---------------------------------------------------------------------------

  // Currently unused: no Presentation consumer is registered.
  //   getIt.registerLazySingleton<GetFavoritesUseCase>(
  //     () => GetFavoritesUseCase(getIt<FavoriteRepository>()),
  //   );

  getIt.registerLazySingleton<AddFavoriteUseCase>(
    () => AddFavoriteUseCase(getIt<FavoriteRepository>()),
  );

  getIt.registerLazySingleton<RemoveFavoriteUseCase>(
    () => RemoveFavoriteUseCase(getIt<FavoriteRepository>()),
  );

  getIt.registerLazySingleton<RefreshFavoritesUseCase>(
    () => RefreshFavoritesUseCase(getIt<FavoriteRepository>()),
  );

  // ---------------------------------------------------------------------------
  // Composite Use Cases
  // ---------------------------------------------------------------------------

  // Currently unused: no Presentation consumer is registered.
  //   getIt.registerLazySingleton<GetGroupsWithCatalogUseCase>(
  //     () => GetGroupsWithCatalogUseCase(
  //       groupRepository: getIt<GroupRepository>(),
  //       catalogItemRepository: getIt<CatalogItemRepository>(),
  //     ),
  //   );

  getIt.registerLazySingleton<GetFavoriteCatalogItemsUseCase>(
    () => GetFavoriteCatalogItemsUseCase(
      favoriteRepository: getIt<FavoriteRepository>(),
      catalogItemRepository: getIt<CatalogItemRepository>(),
    ),
  );

  // Currently unused: no Presentation consumer is registered.
  //   getIt.registerLazySingleton<GetCatalogItemsWithFavoriteStatusUseCase>(
  //     () => GetCatalogItemsWithFavoriteStatusUseCase(
  //       catalogItemRepository: getIt<CatalogItemRepository>(),
  //       favoriteRepository: getIt<FavoriteRepository>(),
  //     ),
  //   );
}

/// Registers presentation dependencies.
void _registerPresentation(GetIt getIt) {
  // ---------------------------------------------------------------------------
  // Catalog Cubit
  // ---------------------------------------------------------------------------

  getIt.registerFactory<CatalogCubit>(
    () => CatalogCubit(
      getGroupsUseCase: getIt<GetGroupsUseCase>(),
      refreshGroupsUseCase: getIt<RefreshGroupsUseCase>(),
      getCatalogItemsUseCase: getIt<GetCatalogItemsUseCase>(),
      refreshCatalogItemsByGroupUseCase:
          getIt<RefreshCatalogItemsByGroupUseCase>(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Favorites Cubit
  // ---------------------------------------------------------------------------

  getIt.registerFactoryParam<FavoritesCubit, String, void>(
    (userId, _) => FavoritesCubit(
      userId: userId,
      getFavoriteCatalogItemsUseCase: getIt<GetFavoriteCatalogItemsUseCase>(),
      addFavoriteUseCase: getIt<AddFavoriteUseCase>(),
      removeFavoriteUseCase: getIt<RemoveFavoriteUseCase>(),
      refreshFavoritesUseCase: getIt<RefreshFavoritesUseCase>(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Catalog Item Details Cubit
  // ---------------------------------------------------------------------------

  getIt.registerFactoryParam<CatalogItemDetailsCubit, String, void>(
    (itemId, _) => CatalogItemDetailsCubit(
      getCatalogItemByIdUseCase: getIt<GetCatalogItemByIdUseCase>(),
      itemId: itemId,
    ),
  );
}

/// Registers a lazy singleton only if it has not been registered before.
///
/// This makes feature initialization safe to call more than once
/// without causing duplicate registration errors.
void _registerLazySingletonIfAbsent<T extends Object>({
  required GetIt getIt,
  required T Function() factory,
}) {
  if (!getIt.isRegistered<T>()) {
    getIt.registerLazySingleton<T>(factory);
  }
}
