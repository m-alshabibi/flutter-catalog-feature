import 'package:flutter_catalog_feature/core/error/exceptions.dart';
import 'package:flutter_catalog_feature/core/error/failures.dart';
import 'package:flutter_catalog_feature/core/result/result.dart';
import 'package:flutter_catalog_feature/features/catalog/data/datasources/local/catalog_item_local_data_source.dart';
import 'package:flutter_catalog_feature/features/catalog/data/datasources/local/group_local_data_source.dart';
import 'package:flutter_catalog_feature/features/catalog/data/datasources/remote/catalog_item_remote_data_source.dart';
import 'package:flutter_catalog_feature/features/catalog/data/models/catalog_item_model.dart';
import 'package:flutter_catalog_feature/features/catalog/data/repositories/catalog_item_repository_impl.dart';
import 'package:flutter_catalog_feature/features/catalog/data/repositories/group_repository_impl.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/catalog_item_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCatalogItemLocalDataSource extends Mock
    implements CatalogItemLocalDataSource {}

class MockCatalogItemRemoteDataSource extends Mock
    implements CatalogItemRemoteDataSource {}

class MockGroupLocalDataSource extends Mock implements GroupLocalDataSource {}

class MockGroupRepository extends Mock implements GroupRepositoryImpl {}

void main() {
  late MockCatalogItemLocalDataSource localDataSource;
  late MockCatalogItemRemoteDataSource remoteDataSource;
  late MockGroupLocalDataSource groupLocalDataSource;
  late MockGroupRepository groupRepository;
  late CatalogItemRepositoryImpl repository;

  late CatalogItemModel item1;
  late CatalogItemModel item2;
  late List<CatalogItemModel> items;
  late Map<String, List<CatalogItemModel>> groupedItems;

  setUp(() {
    localDataSource = MockCatalogItemLocalDataSource();
    remoteDataSource = MockCatalogItemRemoteDataSource();
    groupLocalDataSource = MockGroupLocalDataSource();
    groupRepository = MockGroupRepository();
    repository = CatalogItemRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
      groupLocalDataSource: groupLocalDataSource,
      groupRepository: groupRepository,
    );

    item1 = CatalogItemModel(id: 'item-1', groupId: 'group-1', name: 'Item 1');

    item2 = CatalogItemModel(id: 'item-2', groupId: 'group-2', name: 'Item 2');

    items = [item1, item2];

    groupedItems = {
      'group-1': [item1],
      'group-2': [item2],
    };
  });

  group('getAllCatalogItems', () {
    test('should return grouped items from local data source', () async {
      when(() => localDataSource.getAllCatalogItems())
          .thenAnswer((_) async => groupedItems);

      final result = await repository.getAllCatalogItems();

      expect(result, isA<Success<Map<String, List<CatalogItemEntity>>>>());

      final success = result as Success<Map<String, List<CatalogItemEntity>>>;

      expect(success.data, groupedItems);
      verify(() => localDataSource.getAllCatalogItems()).called(1);
      verifyNever(() => remoteDataSource.getAllCatalogItems());
    });

    test('should map CacheException to CacheFailure', () async {
      when(() => localDataSource.getAllCatalogItems())
          .thenThrow(const CacheException());

      final result = await repository.getAllCatalogItems();

      expect(
        result,
        isA<FailureResult<Map<String, List<CatalogItemEntity>>>>(),
      );

      final failure =
          (result as FailureResult<Map<String, List<CatalogItemEntity>>>)
              .failure;

      expect(failure, isA<CacheFailure>());
    });

    test('should map unexpected errors to UnknownFailure', () async {
      when(() => localDataSource.getAllCatalogItems())
          .thenThrow(StateError('Unexpected error'));

      final result = await repository.getAllCatalogItems();

      expect(
        result,
        isA<FailureResult<Map<String, List<CatalogItemEntity>>>>(),
      );

      final failure =
          (result as FailureResult<Map<String, List<CatalogItemEntity>>>)
              .failure;

      expect(failure, isA<UnknownFailure>());
    });
  });

  group('getCatalogItems', () {
    test('should return items for the requested group', () async {
      when(() => localDataSource.getCatalogItems('group-1'))
          .thenAnswer((_) async => [item1]);

      final result = await repository.getCatalogItems('group-1');

      expect(result, isA<Success<List<CatalogItemEntity>>>());

      final success = result as Success<List<CatalogItemEntity>>;

      expect(success.data, [item1]);
      verify(() => localDataSource.getCatalogItems('group-1')).called(1);
    });

    test('should map AppException to the corresponding Failure', () async {
      when(() => localDataSource.getCatalogItems('group-1'))
          .thenThrow(const CacheException());

      final result = await repository.getCatalogItems('group-1');

      expect(result, isA<FailureResult<List<CatalogItemEntity>>>());

      final failure =
          (result as FailureResult<List<CatalogItemEntity>>).failure;

      expect(failure, isA<CacheFailure>());
    });
  });

  group('getCatalogItemsByIds', () {
    test('should return items matching the requested IDs', () async {
      final ids = {'item-1', 'item-2'};

      when(() => localDataSource.getCatalogItemsByIds(ids))
          .thenAnswer((_) async => items);

      final result = await repository.getCatalogItemsByIds(ids);

      expect(result, isA<Success<List<CatalogItemEntity>>>());

      final success = result as Success<List<CatalogItemEntity>>;

      expect(success.data, items);
      verify(() => localDataSource.getCatalogItemsByIds(ids)).called(1);
    });

    test('should map CacheException to CacheFailure', () async {
      final ids = {'item-1'};

      when(() => localDataSource.getCatalogItemsByIds(ids))
          .thenThrow(const CacheException());

      final result = await repository.getCatalogItemsByIds(ids);

      expect(result, isA<FailureResult<List<CatalogItemEntity>>>());

      final failure =
          (result as FailureResult<List<CatalogItemEntity>>).failure;

      expect(failure, isA<CacheFailure>());
    });
  });

  group('getCatalogItemById', () {
    test('should return the requested item from local data source', () async {
      when(() => localDataSource.getCatalogItemById('item-1'))
          .thenAnswer((_) async => item1);

      final result = await repository.getCatalogItemById('item-1');

      expect(result, isA<Success<CatalogItemEntity>>());

      final success = result as Success<CatalogItemEntity>;

      expect(success.data, item1);
      verify(() => localDataSource.getCatalogItemById('item-1')).called(1);
    });

    test('should map NotFoundException to NotFoundFailure', () async {
      when(() => localDataSource.getCatalogItemById('missing'))
          .thenThrow(const NotFoundException());

      final result = await repository.getCatalogItemById('missing');

      expect(result, isA<FailureResult<CatalogItemEntity>>());

      final failure = (result as FailureResult<CatalogItemEntity>).failure;

      expect(failure, isA<NotFoundFailure>());
    });
  });

  group('refreshCatalogItems', () {
    test('should fetch all remote items and save them locally', () async {
      when(() => remoteDataSource.getAllCatalogItems())
          .thenAnswer((_) async => groupedItems);

      when(() => localDataSource.saveCatalogItems(items))
          .thenAnswer((_) async {});

      final result = await repository.refreshCatalogItems();

      expect(result, isA<Success<void>>());

      verify(() => remoteDataSource.getAllCatalogItems()).called(1);
      verify(() => localDataSource.saveCatalogItems(items)).called(1);
    });

    test('should map remote AppException and skip local saving', () async {
      when(() => remoteDataSource.getAllCatalogItems())
          .thenThrow(const NetworkException());

      final result = await repository.refreshCatalogItems();

      expect(result, isA<FailureResult<void>>());

      final failure = (result as FailureResult<void>).failure;

      expect(failure, isA<NetworkFailure>());
      verifyNever(() => localDataSource.saveCatalogItems(items));
    });

    test('should map local save exception to CacheFailure', () async {
      when(() => remoteDataSource.getAllCatalogItems())
          .thenAnswer((_) async => groupedItems);

      when(() => localDataSource.saveCatalogItems(items))
          .thenThrow(const CacheException());

      final result = await repository.refreshCatalogItems();

      expect(result, isA<FailureResult<void>>());

      final failure = (result as FailureResult<void>).failure;

      expect(failure, isA<CacheFailure>());
    });
  });

  group('refreshCatalogItemsByGroup', () {
    test('should fetch and save items for the requested group', () async {
      when(() => remoteDataSource.getCatalogItems('group-1'))
          .thenAnswer((_) async => [item1]);

      // The requested group already exists locally, so no group refresh is needed.
      when(() => groupLocalDataSource.getStoredGroupIds({'group-1'}))
          .thenAnswer((_) async => {'group-1'});

      when(() => localDataSource.saveCatalogItems([item1]))
          .thenAnswer((_) async {});

      final result = await repository.refreshCatalogItemsByGroup('group-1');

      expect(result, isA<Success<void>>());

      verify(() => remoteDataSource.getCatalogItems('group-1')).called(1);
      verify(() => localDataSource.saveCatalogItems([item1])).called(1);
    });

    test(
      'should map remote AppException to the corresponding Failure',
      () async {
        when(() => remoteDataSource.getCatalogItems('group-1'))
            .thenThrow(const NetworkException());

        final result = await repository.refreshCatalogItemsByGroup('group-1');

        expect(result, isA<FailureResult<void>>());

        final failure = (result as FailureResult<void>).failure;

        expect(failure, isA<NetworkFailure>());
        verifyNever(() => localDataSource.saveCatalogItems([item1]));
      },
    );

    test('should map local save exception to CacheFailure', () async {
      when(() => remoteDataSource.getCatalogItems('group-1'))
          .thenAnswer((_) async => [item1]);

      // Keep group lookup successful so this test reaches the local save operation.
      when(() => groupLocalDataSource.getStoredGroupIds({'group-1'}))
          .thenAnswer((_) async => {'group-1'});

      when(() => localDataSource.saveCatalogItems([item1]))
          .thenThrow(const CacheException());

      final result = await repository.refreshCatalogItemsByGroup('group-1');

      expect(result, isA<FailureResult<void>>());

      final failure = (result as FailureResult<void>).failure;

      expect(failure, isA<CacheFailure>());
    });
  });
}
