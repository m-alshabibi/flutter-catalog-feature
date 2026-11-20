import '../../../../core/domain/usecases/no_params.dart';
import '../../../../core/domain/usecases/use_case.dart';
import '../../../../core/result/result.dart';
import '../repositories/catalog_item_repository.dart';

class RefreshCatalogItemsUseCase implements UseCase<void, NoParams> {
  final CatalogItemRepository _repository;

  RefreshCatalogItemsUseCase(this._repository);

  @override
  Future<Result<void>> call(NoParams params) {
    return _repository.refreshCatalogItems();
  }
}
