import 'package:flutter/material.dart';

import '../../domain/entities/group_entity.dart';
import '../widgets/groups/groups_view.dart';

class CatalogPage extends StatelessWidget {
  /// Navigation is delegated to the host application.
  final ValueChanged<GroupEntity> onGroupTap;

  const CatalogPage({super.key, required this.onGroupTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catalog')),
      body: GroupsView(onGroupTap: onGroupTap),
    );
  }
}
