import '../../../../core/domain/usecases/no_params.dart';
import '../../../../core/domain/usecases/use_case.dart';
import '../../../../core/result/result.dart';
import '../entities/catalog_item_entity.dart';
import '../repositories/catalog_item_repository.dart';

class GetAllCatalogItemsUseCase
    implements UseCase<Map<String, List<CatalogItemEntity>>, NoParams> {
  final CatalogItemRepository _repository;

  GetAllCatalogItemsUseCase(this._repository);

  @override
  Future<Result<Map<String, List<CatalogItemEntity>>>> call(NoParams params) {
    return _repository.getAllCatalogItems();
  }
}
