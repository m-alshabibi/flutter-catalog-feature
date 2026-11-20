import '../../../../core/domain/usecases/use_case.dart';
import '../../../../core/result/result.dart';
import '../entities/catalog_item_entity.dart';
import '../repositories/catalog_item_repository.dart';

class GetCatalogItemsUseCase
    implements UseCase<List<CatalogItemEntity>, String> {
  final CatalogItemRepository _repository;

  GetCatalogItemsUseCase(this._repository);

  @override
  Future<Result<List<CatalogItemEntity>>> call(String groupId) {
    return _repository.getCatalogItems(groupId);
  }
}
