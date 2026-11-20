import '../../../../core/domain/usecases/no_params.dart';
import '../../../../core/domain/usecases/use_case.dart';
import '../../../../core/result/result.dart';
import '../entities/catalog_item_entity.dart';
import '../entities/group_entity.dart';
import '../models/group_with_catalog.dart';
import '../repositories/catalog_item_repository.dart';
import '../repositories/group_repository.dart';

class GetGroupsWithCatalogUseCase
    implements UseCase<List<GroupWithCatalog>, NoParams> {
  final GroupRepository _groupRepository;
  final CatalogItemRepository _catalogItemRepository;

  GetGroupsWithCatalogUseCase({
    required this._groupRepository,
    required this._catalogItemRepository,
  });

  @override
  Future<Result<List<GroupWithCatalog>>> call(NoParams params) async {
    final groupsResult = await _groupRepository.getGroups();

    if (groupsResult is FailureResult<List<GroupEntity>>) {
      return FailureResult<List<GroupWithCatalog>>(groupsResult.failure);
    }

    final groups = (groupsResult as Success<List<GroupEntity>>).data;

    final catalogResult = await _catalogItemRepository.getAllCatalogItems();

    if (catalogResult is FailureResult<Map<String, List<CatalogItemEntity>>>) {
      return FailureResult<List<GroupWithCatalog>>(catalogResult.failure);
    }

    final catalogItemsByGroup =
        (catalogResult as Success<Map<String, List<CatalogItemEntity>>>).data;

    final result = groups.map((group) {
      return GroupWithCatalog(
        group: group,
        catalogItems: catalogItemsByGroup[group.id] ?? <CatalogItemEntity>[],
      );
    }).toList();

    return Success<List<GroupWithCatalog>>(result);
  }
}
