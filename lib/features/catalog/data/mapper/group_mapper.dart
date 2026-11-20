import 'package:drift/drift.dart';

import '../datasources/local/database/app_database.dart';
import '../models/group_model.dart';

class GroupMapper {
  static GroupModel mapToModel(GroupsTableData row) {
    return GroupModel(
      id: row.id,
      name: row.name,
      description: row.description,
      imageUrl: row.imageUrl,
      sortOrder: row.sortOrder,
      isActive: row.isActive,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static Insertable<GroupsTableData> modelToMap(GroupModel group) {
    return GroupsTableCompanion.insert(
      id: group.id,
      name: group.name,
      description: Value(group.description),
      imageUrl: Value(group.imageUrl),
      sortOrder: Value(group.sortOrder),
      isActive: Value(group.isActive),
      createdAt: group.createdAt,
      updatedAt: group.updatedAt,
    );
  }
}
