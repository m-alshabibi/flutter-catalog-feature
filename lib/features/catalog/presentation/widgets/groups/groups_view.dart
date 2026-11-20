import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/group_entity.dart';
import '../../components/common/state/app_state_view.dart';
import '../../controllers/catalog/catalog_cubit.dart';
import '../../controllers/catalog/catalog_state.dart';
import 'group_grid.dart';
import 'group_item.dart';
import 'group_list.dart';

enum GroupsViewLayout { list, grid }

class GroupsView extends StatelessWidget {
  final GroupsViewLayout layout;
  final ValueChanged<GroupEntity>? onGroupTap;
  final GroupItemBuilder? itemBuilder;
  final EdgeInsetsGeometry? padding;
  final double spacing;
  final int crossAxisCount;
  final double childAspectRatio;

  const GroupsView({
    super.key,
    this.layout = GroupsViewLayout.list,
    this.onGroupTap,
    this.itemBuilder,
    this.padding,
    this.spacing = 8,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.2,
  }) : assert(crossAxisCount > 0);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogCubit, CatalogState>(
      builder: (context, state) {
        return AppStateView<CatalogState>(
          state: state,
          isEmpty: state.groups.isEmpty,
          onRetry: () => context.read<CatalogCubit>().retryLoadGroups(),
          contentBuilder: (state) {
            switch (layout) {
              case GroupsViewLayout.list:
                return GroupList(
                  groups: state.groups,
                  onGroupTap: onGroupTap,
                  itemBuilder: itemBuilder,
                  padding: padding,
                  spacing: spacing,
                );

              case GroupsViewLayout.grid:
                return GroupGrid(
                  groups: state.groups,
                  onGroupTap: onGroupTap,
                  itemBuilder: itemBuilder,
                  padding: padding,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                );
            }
          },
        );
      },
    );
  }
}
