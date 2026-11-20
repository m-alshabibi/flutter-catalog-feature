import '../../../../core/result/result.dart';
import '../entities/group_entity.dart';

abstract interface class GroupRepository {
  /// Retrieves groups from the available local data.
  Future<Result<List<GroupEntity>>> getGroups();

  /// Fetches the latest groups from the remote source
  /// and updates the local cache.
  Future<Result<void>> refreshGroups();
}
