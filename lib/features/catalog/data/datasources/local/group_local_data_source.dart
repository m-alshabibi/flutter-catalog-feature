import 'package:drift/drift.dart';

import '../../mapper/group_mapper.dart';
import '../../models/group_model.dart';
import 'database/app_database.dart';

abstract interface class GroupLocalDataSource {
  /// Retrieves active groups stored in the local database.
  Future<List<GroupModel>> getGroups();

  /// Returns IDs of groups already stored locally, including inactive groups.
  Future<Set<String>> getStoredGroupIds(Set<String> ids);

  /// Applies a complete remote groups snapshot to the local database.
  Future<void> syncGroups(List<GroupModel> groups);
}

class GroupLocalDataSourceImpl implements GroupLocalDataSource {
  final AppDatabase _database;

  GroupLocalDataSourceImpl(this._database);

  @override
  Future<List<GroupModel>> getGroups() async {
    final query = _database.select(_database.groupsTable)
      ..where((table) => table.isActive.equals(true))
      ..orderBy([
        (table) => OrderingTerm.asc(table.sortOrder),
        (table) => OrderingTerm.asc(table.name),
      ]);

    final rows = await query.get();

    return rows.map(GroupMapper.mapToModel).toList();
  }

  @override
  Future<Set<String>> getStoredGroupIds(Set<String> ids) async {
    if (ids.isEmpty) return <String>{};

    final rows = await (_database.select(_database.groupsTable)
          ..where((table) => table.id.isIn(ids)))
        .get();

    return rows.map((row) => row.id).toSet();
  }

  @override
  Future<void> syncGroups(List<GroupModel> groups) async {
    await _database.transaction(() async {
      for (final group in groups) {
        await _database
            .into(_database.groupsTable)
            .insertOnConflictUpdate(GroupMapper.modelToMap(group));
      }

      final receivedIds = groups.map((group) => group.id).toSet();

      if (receivedIds.isEmpty) {
        await _database.update(_database.groupsTable).write(
          const GroupsTableCompanion(isActive: Value(false)),
        );
      } else {
        await (_database.update(_database.groupsTable)
              ..where((table) => table.id.isNotIn(receivedIds)))
            .write(
          const GroupsTableCompanion(isActive: Value(false)),
        );
      }
    });
  }
}
