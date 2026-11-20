import '../../../../core/domain/usecases/no_params.dart';
import '../../../../core/domain/usecases/use_case.dart';
import '../../../../core/result/result.dart';
import '../repositories/group_repository.dart';

class RefreshGroupsUseCase implements UseCase<void, NoParams> {
  final GroupRepository _repository;

  RefreshGroupsUseCase(this._repository);

  @override
  Future<Result<void>> call(NoParams params) {
    return _repository.refreshGroups();
  }
}
