import '../../../../core/domain/usecases/no_params.dart';
import '../../../../core/domain/usecases/use_case.dart';
import '../../../../core/result/result.dart';
import '../entities/group_entity.dart';
import '../repositories/group_repository.dart';

class GetGroupsUseCase implements UseCase<List<GroupEntity>, NoParams> {
  final GroupRepository _repository;

  GetGroupsUseCase(this._repository);

  @override
  Future<Result<List<GroupEntity>>> call(NoParams params) {
    return _repository.getGroups();
  }
}
