import '../../../../core/domain/usecases/use_case.dart';
import '../../../../core/result/result.dart';
import '../repositories/catalog_item_repository.dart';

class RefreshCatalogItemsByGroupUseCase implements UseCase<void, String> {
  final CatalogItemRepository _repository;

  RefreshCatalogItemsByGroupUseCase(this._repository);

  @override
  Future<Result<void>> call(String groupId) {
    return _repository.refreshCatalogItemsByGroup(groupId);
  }
}
