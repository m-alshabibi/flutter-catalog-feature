import 'package:flutter/material.dart';

import '../../domain/entities/catalog_item_entity.dart';
import '../../domain/entities/group_entity.dart';
import '../widgets/catalog_items/group_catalog_view.dart';

class GroupCatalogPage extends StatelessWidget {
  final GroupEntity group;
  final ValueChanged<CatalogItemEntity> onItemTap;

  const GroupCatalogPage({
    super.key,
    required this.group,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(group.name)),
      body: GroupCatalogView(groupId: group.id, onItemTap: onItemTap),
    );
  }
}
