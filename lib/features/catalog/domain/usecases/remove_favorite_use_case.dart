import '../../../../core/domain/usecases/use_case.dart';
import '../../../../core/result/result.dart';
import '../repositories/favorite_repository.dart';
import 'params/add_favorite_params.dart';

class RemoveFavoriteUseCase implements UseCase<void, AddFavoriteParams> {
  final FavoriteRepository _repository;

  RemoveFavoriteUseCase(this._repository);

  @override
  Future<Result<void>> call(AddFavoriteParams params) {
    return _repository.removeFavorite(params.userId, params.catalogItemId);
  }
}
