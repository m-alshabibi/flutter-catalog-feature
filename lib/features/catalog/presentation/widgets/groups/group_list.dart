import 'package:flutter/material.dart';

import '../../../../../core/presentation/widgets/app_list_view.dart';
import '../../../domain/entities/group_entity.dart';
import 'group_item.dart';

class GroupList extends StatelessWidget {
  final List<GroupEntity> groups;
  final ValueChanged<GroupEntity>? onGroupTap;
  final GroupItemBuilder? itemBuilder;
  final Axis scrollDirection;
  final EdgeInsetsGeometry? padding;
  final double spacing;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const GroupList({
    super.key,
    required this.groups,
    this.onGroupTap,
    this.itemBuilder,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.spacing = 8,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return AppListView<GroupEntity>(
      items: groups,
      onItemTap: onGroupTap,
      scrollDirection: scrollDirection,
      padding: padding,
      spacing: spacing,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemBuilder: (context, group) {
        return itemBuilder?.call(context, group) ?? GroupItem(group: group);
      },
    );
  }
}
