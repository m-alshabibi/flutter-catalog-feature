import '../../../../core/error/exception_to_failure_mapper.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../common/typedefs/catalog_types.dart';
import '../../domain/entities/catalog_item_entity.dart';
import '../../domain/repositories/catalog_item_repository.dart';
import '../../domain/repositories/group_repository.dart';
import '../datasources/local/catalog_item_local_data_source.dart';
import '../datasources/local/group_local_data_source.dart';
import '../datasources/remote/catalog_item_remote_data_source.dart';
import '../models/catalog_item_model.dart';

class CatalogItemRepositoryImpl implements CatalogItemRepository {
  final CatalogItemLocalDataSource _localDataSource;
  final CatalogItemRemoteDataSource _remoteDataSource;
  final GroupLocalDataSource _groupLocalDataSource;
  final GroupRepository _groupRepository;

  CatalogItemRepositoryImpl({
    required CatalogItemLocalDataSource localDataSource,
    required CatalogItemRemoteDataSource remoteDataSource,
    required GroupLocalDataSource groupLocalDataSource,
    required GroupRepository groupRepository,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource,
       _groupLocalDataSource = groupLocalDataSource,
       _groupRepository = groupRepository;

  @override
  Future<Result<CatalogItemsByGroup>> getAllCatalogItems() async {
    try {
      final items = await _localDataSource.getAllCatalogItems();
      return Success<CatalogItemsByGroup>(items);
    } on AppException catch (exception) {
      return FailureResult<CatalogItemsByGroup>(
        ExceptionToFailureMapper.map(exception),
      );
    } catch (error) {
      return FailureResult<CatalogItemsByGroup>(
        UnknownFailure(error.toString()),
      );
    }
  }

  @override
  Future<Result<List<CatalogItemEntity>>> getCatalogItems(
    String groupId,
  ) async {
    try {
      final items = await _localDataSource.getCatalogItems(groupId);
      return Success<List<CatalogItemEntity>>(items);
    } on AppException catch (exception) {
      return FailureResult<List<CatalogItemEntity>>(
        ExceptionToFailureMapper.map(exception),
      );
    } catch (error) {
      return FailureResult<List<CatalogItemEntity>>(
        UnknownFailure(error.toString()),
      );
    }
  }

  @override
  Future<Result<List<CatalogItemEntity>>> getCatalogItemsByIds(
    Set<String> ids,
  ) async {
    try {
      if (ids.isEmpty) {
        return const Success<List<CatalogItemEntity>>([]);
      }

      final localItems = await _localDataSource.getCatalogItemsByIds(ids);
      final cachedIds = localItems.map((item) => item.id).toSet();
      final missingIds = ids.difference(cachedIds);

      if (missingIds.isEmpty) {
        return Success<List<CatalogItemEntity>>(localItems);
      }

      final remoteItems = await Future.wait<CatalogItemModel>(
        missingIds.map(_remoteDataSource.getCatalogItemById),
      );

      final groupsResult = await _ensureParentGroups(remoteItems);
      if (groupsResult is FailureResult<void>) {
        return FailureResult<List<CatalogItemEntity>>(groupsResult.failure);
      }

      await _localDataSource.saveCatalogItems(remoteItems);

      return Success<List<CatalogItemEntity>>([
        ...localItems,
        ...remoteItems,
      ]);
    } on AppException catch (exception) {
      return FailureResult<List<CatalogItemEntity>>(
        ExceptionToFailureMapper.map(exception),
      );
    } catch (error) {
      return FailureResult<List<CatalogItemEntity>>(
        UnknownFailure(error.toString()),
      );
    }
  }

  @override
  Future<Result<CatalogItemEntity>> getCatalogItemById(String id) async {
    try {
      final localItem = await _localDataSource.getCatalogItemById(id);
      if (localItem != null) {
        return Success<CatalogItemEntity>(localItem);
      }

      final remoteItem = await _remoteDataSource.getCatalogItemById(id);
      final groupsResult = await _ensureParentGroups([remoteItem]);

      if (groupsResult is FailureResult<void>) {
        return FailureResult<CatalogItemEntity>(groupsResult.failure);
      }

      await _localDataSource.saveCatalogItems([remoteItem]);
      return Success<CatalogItemEntity>(remoteItem);
    } on AppException catch (exception) {
      return FailureResult<CatalogItemEntity>(
        ExceptionToFailureMapper.map(exception),
      );
    } catch (error) {
      return FailureResult<CatalogItemEntity>(
        UnknownFailure(error.toString()),
      );
    }
  }

  @override
  Future<Result<void>> refreshCatalogItems() async {
    try {
      final groupedItems = await _remoteDataSource.getAllCatalogItems();
      final items = groupedItems.values
          .expand((groupItems) => groupItems)
          .toList();

      final groupsResult = await _ensureParentGroups(items);
      if (groupsResult is FailureResult<void>) {
        return groupsResult;
      }

      await _localDataSource.syncCatalogItems(items);
      return const Success<void>(null);
    } on AppException catch (exception) {
      return FailureResult<void>(ExceptionToFailureMapper.map(exception));
    } catch (error) {
      return FailureResult<void>(UnknownFailure(error.toString()));
    }
  }

  @override
  Future<Result<void>> refreshCatalogItemsByGroup(String groupId) async {
    try {
      final items = await _remoteDataSource.getCatalogItems(groupId);

      final groupsResult = await _ensureParentGroups(items);
      if (groupsResult is FailureResult<void>) {
        return groupsResult;
      }

      await _localDataSource.syncCatalogItems(items, groupId: groupId);
      return const Success<void>(null);
    } on AppException catch (exception) {
      return FailureResult<void>(ExceptionToFailureMapper.map(exception));
    } catch (error) {
      return FailureResult<void>(UnknownFailure(error.toString()));
    }
  }

  Future<Result<void>> _ensureParentGroups(
    List<CatalogItemModel> items,
  ) async {
    final requiredGroupIds = items.map((item) => item.groupId).toSet();
    if (requiredGroupIds.isEmpty) return const Success<void>(null);

    final storedGroupIds = await _groupLocalDataSource.getStoredGroupIds(
      requiredGroupIds,
    );
    final missingGroupIds = requiredGroupIds.difference(storedGroupIds);

    if (missingGroupIds.isEmpty) return const Success<void>(null);

    final refreshResult = await _groupRepository.refreshGroups();
    if (refreshResult is FailureResult<void>) {
      return refreshResult;
    }

    final refreshedGroupIds = await _groupLocalDataSource.getStoredGroupIds(
      missingGroupIds,
    );
    final unresolvedGroupIds = missingGroupIds.difference(refreshedGroupIds);

    if (unresolvedGroupIds.isNotEmpty) {
      return const FailureResult<void>(
        NotFoundFailure('A catalog item references a group that does not exist.'),
      );
    }

    return const Success<void>(null);
  }
}
