import '../../../../core/domain/usecases/use_case.dart';
import '../../../../core/result/result.dart';
import '../entities/catalog_item_entity.dart';
import '../repositories/catalog_item_repository.dart';

class GetCatalogItemByIdUseCase implements UseCase<CatalogItemEntity, String> {
  final CatalogItemRepository _repository;

  GetCatalogItemByIdUseCase(this._repository);

  @override
  Future<Result<CatalogItemEntity>> call(String id) {
    return _repository.getCatalogItemById(id);
  }
}
