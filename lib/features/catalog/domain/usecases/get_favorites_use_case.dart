import '../../../../core/domain/usecases/use_case.dart';
import '../../../../core/result/result.dart';
import '../entities/favorite_entity.dart';
import '../repositories/favorite_repository.dart';

class GetFavoritesUseCase implements UseCase<List<FavoriteEntity>, String> {
  final FavoriteRepository _repository;

  GetFavoritesUseCase(this._repository);

  @override
  Future<Result<List<FavoriteEntity>>> call(String userId) {
    return _repository.getFavorites(userId);
  }
}
