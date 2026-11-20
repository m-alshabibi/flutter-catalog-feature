import '../../../../core/domain/usecases/use_case.dart';
import '../../../../core/result/result.dart';
import '../entities/catalog_item_entity.dart';
import '../repositories/catalog_item_repository.dart';

class GetCatalogItemsByIdsUseCase
    implements UseCase<List<CatalogItemEntity>, Set<String>> {
  final CatalogItemRepository _repository;

  GetCatalogItemsByIdsUseCase(this._repository);

  @override
  Future<Result<List<CatalogItemEntity>>> call(Set<String> ids) {
    return _repository.getCatalogItemsByIds(ids);
  }
}
