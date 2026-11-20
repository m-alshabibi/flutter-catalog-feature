import 'package:flutter/material.dart';

import '../../../../../core/presentation/widgets/app_grid_view.dart';
import '../../../domain/entities/group_entity.dart';
import 'group_item.dart';

class GroupGrid extends StatelessWidget {
  final List<GroupEntity> groups;
  final ValueChanged<GroupEntity>? onGroupTap;
  final GroupItemBuilder? itemBuilder;

  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const GroupGrid({
    super.key,
    required this.groups,
    this.onGroupTap,
    this.itemBuilder,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 8,
    this.crossAxisSpacing = 8,
    this.childAspectRatio = 1.2,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  }) : assert(crossAxisCount > 0);

  @override
  Widget build(BuildContext context) {
    return AppGridView<GroupEntity>(
      items: groups,
      onItemTap: onGroupTap,
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      childAspectRatio: childAspectRatio,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemBuilder: (context, group) {
        return itemBuilder?.call(context, group) ?? GroupItem(group: group);
      },
    );
  }
}
