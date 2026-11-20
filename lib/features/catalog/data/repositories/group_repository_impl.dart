import '../../../../core/error/exception_to_failure_mapper.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/repositories/group_repository.dart';
import '../datasources/local/group_local_data_source.dart';
import '../datasources/remote/group_remote_data_source.dart';

class GroupRepositoryImpl implements GroupRepository {
  final GroupLocalDataSource _localDataSource;
  final GroupRemoteDataSource _remoteDataSource;

  GroupRepositoryImpl({
    required this._localDataSource,
    required this._remoteDataSource,
  });

  @override
  Future<Result<List<GroupEntity>>> getGroups() async {
    try {
      final groups = await _localDataSource.getGroups();

      return Success<List<GroupEntity>>(groups);
    } on AppException catch (exception) {
      return FailureResult<List<GroupEntity>>(
        ExceptionToFailureMapper.map(exception),
      );
    } catch (_) {
      return const FailureResult<List<GroupEntity>>(UnknownFailure());
    }
  }

  @override
  Future<Result<void>> refreshGroups() async {
    try {
      final groups = await _remoteDataSource.getGroups();

      await _localDataSource.syncGroups(groups);

      return const Success<void>(null);
    } on AppException catch (exception) {
      return FailureResult<void>(ExceptionToFailureMapper.map(exception));
    } catch (_) {
      return const FailureResult<void>(UnknownFailure());
    }
  }
}
