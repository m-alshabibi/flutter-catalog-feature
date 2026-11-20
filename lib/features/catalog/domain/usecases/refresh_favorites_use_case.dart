import '../../../../core/domain/usecases/use_case.dart';
import '../../../../core/result/result.dart';
import '../repositories/favorite_repository.dart';

class RefreshFavoritesUseCase implements UseCase<void, String> {
  final FavoriteRepository _repository;

  RefreshFavoritesUseCase(this._repository);

  @override
  Future<Result<void>> call(String userId) {
    return _repository.refreshFavorites(userId);
  }
}
