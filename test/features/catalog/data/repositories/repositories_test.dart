import 'package:flutter_catalog_feature/core/error/exceptions.dart';
import 'package:flutter_catalog_feature/core/error/failures.dart';
import 'package:flutter_catalog_feature/core/result/result.dart';
import 'package:flutter_catalog_feature/features/catalog/data/repositories/catalog_item_repository_impl.dart';
import 'package:flutter_catalog_feature/features/catalog/data/repositories/favorite_repository_impl.dart';
import 'package:flutter_catalog_feature/features/catalog/data/repositories/group_repository_impl.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/catalog_item_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/group_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fake_data_sources.dart';
import '../../../../support/fake_repositories.dart';
import '../../../../support/fixtures.dart';

void main() {
  group('GroupRepositoryImpl', () {
    test('reads cached groups', () async {
      final local = FakeGroupLocalDataSource()..groups = [makeGroupModel()];
      final repository = GroupRepositoryImpl(
        localDataSource: local,
        remoteDataSource: FakeGroupRemoteDataSource(),
      );
      final result = await repository.getGroups();
      expect((result as Success<List<GroupEntity>>).data.single.id, 'group-1');
    });

    test('refreshes from remote and updates local snapshot', () async {
      final local = FakeGroupLocalDataSource();
      final remote = FakeGroupRemoteDataSource()..groups = [makeGroupModel()];
      final repository = GroupRepositoryImpl(
        localDataSource: local,
        remoteDataSource: remote,
      );
      expect(await repository.refreshGroups(), isA<Success<void>>());
      expect(local.lastSynced!.single.id, 'group-1');
    });

    test('maps local application exceptions to failures', () async {
      final repository = GroupRepositoryImpl(
        localDataSource: FakeGroupLocalDataSource()
          ..error = const CacheException('cache'),
        remoteDataSource: FakeGroupRemoteDataSource(),
      );
      final result = await repository.getGroups();
      expect((result as FailureResult).failure, isA<CacheFailure>());
    });
  });

  group('CatalogItemRepositoryImpl', () {
    test(
      'loads a missing item remotely after confirming its parent group exists',
      () async {
        final local = FakeCatalogItemLocalDataSource();
        final remote = FakeCatalogItemRemoteDataSource()
          ..byId['item-1'] = makeItemModel();
        final groupLocal = FakeGroupLocalDataSource()..storedIds = {'group-1'};
        final repository = CatalogItemRepositoryImpl(
          localDataSource: local,
          remoteDataSource: remote,
          groupLocalDataSource: groupLocal,
          groupRepository: FakeGroupRepository(),
        );

        final result = await repository.getCatalogItemById('item-1');
        expect((result as Success<CatalogItemEntity>).data.id, 'item-1');
        expect(local.lastSaved!.single.id, 'item-1');
      },
    );

    test(
      'fails when remote item references a group that cannot be resolved',
      () async {
        final groupRepository = FakeGroupRepository();
        final repository = CatalogItemRepositoryImpl(
          localDataSource: FakeCatalogItemLocalDataSource(),
          remoteDataSource: FakeCatalogItemRemoteDataSource()
            ..byId['item-1'] = makeItemModel(),
          groupLocalDataSource: FakeGroupLocalDataSource(),
          groupRepository: groupRepository,
        );
        final result = await repository.getCatalogItemById('item-1');
        expect((result as FailureResult).failure, isA<NotFoundFailure>());
        expect(groupRepository.refreshCalls, 1);
      },
    );

    test(
      "refreshes one group's catalog using the group-scoped snapshot",
      () async {
        final local = FakeCatalogItemLocalDataSource();
        final remote = FakeCatalogItemRemoteDataSource()
          ..grouped['group-1'] = [makeItemModel()];
        final repository = CatalogItemRepositoryImpl(
          localDataSource: local,
          remoteDataSource: remote,
          groupLocalDataSource: FakeGroupLocalDataSource()
            ..storedIds = {'group-1'},
          groupRepository: FakeGroupRepository(),
        );
        expect(
          await repository.refreshCatalogItemsByGroup('group-1'),
          isA<Success<void>>(),
        );
        expect(local.lastSyncGroupId, 'group-1');
        expect(local.lastSynced!.single.id, 'item-1');
      },
    );

    test('returns local items without remote requests when all requested IDs are cached', () async {
      final local = FakeCatalogItemLocalDataSource()
        ..grouped['group-1'] = [makeItemModel()];
      final remote = FakeCatalogItemRemoteDataSource();
      final repository = CatalogItemRepositoryImpl(
        localDataSource: local,
        remoteDataSource: remote,
        groupLocalDataSource: FakeGroupLocalDataSource(),
        groupRepository: FakeGroupRepository(),
      );
      final result = await repository.getCatalogItemsByIds({'item-1'});
      expect(
        (result as Success<List<CatalogItemEntity>>).data.single.id,
        'item-1',
      );
      expect(remote.byId, isEmpty);
    });
  });

  group('FavoriteRepositoryImpl', () {
    test('stores a favorite locally and treats remote synchronization as best effort', () async {
      final local = FakeFavoriteLocalDataSource();
      final repository = FavoriteRepositoryImpl(
        localDataSource: local,
        remoteDataSource: FakeFavoriteRemoteDataSource(),
        catalogItemRepository: FakeCatalogItemRepository(),
      );
      final result = await repository.addFavorite('user-1', 'item-1');
      expect(result, isA<Success<void>>());
      expect(local.saved!.userId, 'user-1');
      expect(local.saved!.catalogItemId, 'item-1');
      expect(local.saved!.id, isNotEmpty);
    });

    test(
      'refreshes server favorites after confirming referenced items are cached',
      () async {
        final local = FakeFavoriteLocalDataSource();
        final remote = FakeFavoriteRemoteDataSource()
          ..favorites = [makeFavoriteModel()];
        final catalog = FakeCatalogItemRepository()
          ..itemsByIdsResult = Success([makeItem()]);
        final repository = FavoriteRepositoryImpl(
          localDataSource: local,
          remoteDataSource: remote,
          catalogItemRepository: catalog,
        );

        final result = await repository.refreshFavorites('user-1');
        expect(result, isA<Success<void>>());
        expect(catalog.lastIds, {'item-1'});
        expect(local.syncUserId, 'user-1');
        expect(local.synced!.single.catalogItemId, 'item-1');
      },
    );

    test(
      'does not sync a favorite whose catalog item cannot be resolved',
      () async {
        final local = FakeFavoriteLocalDataSource();
        final repository = FavoriteRepositoryImpl(
          localDataSource: local,
          remoteDataSource: FakeFavoriteRemoteDataSource()
            ..favorites = [makeFavoriteModel()],
          catalogItemRepository: FakeCatalogItemRepository()
            ..itemsByIdsResult = const Success<List<CatalogItemEntity>>([]),
        );
        final result = await repository.refreshFavorites('user-1');
        expect((result as FailureResult).failure, isA<NotFoundFailure>());
        expect(local.synced, isNull);
      },
    );

    test('maps local exceptions to failure results', () async {
      final repository = FavoriteRepositoryImpl(
        localDataSource: FakeFavoriteLocalDataSource()
          ..error = const CacheException('cache'),
        remoteDataSource: FakeFavoriteRemoteDataSource(),
        catalogItemRepository: FakeCatalogItemRepository(),
      );
      final result = await repository.getFavorites('user-1');
      expect((result as FailureResult).failure, isA<CacheFailure>());
    });
  });
}
