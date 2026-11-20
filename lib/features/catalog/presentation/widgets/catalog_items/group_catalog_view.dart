import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/catalog_item_entity.dart';
import '../../components/common/state/app_state_view.dart';
import '../../controllers/catalog/catalog_cubit.dart';
import '../../controllers/catalog/catalog_state.dart';
import '../../controllers/catalog/group_catalog_state.dart';
import 'catalog_item_card.dart';
import 'catalog_item_grid.dart';
import 'catalog_item_list.dart';

enum GroupCatalogViewLayout { list, grid }

class GroupCatalogView extends StatefulWidget {
  final String groupId;
  final GroupCatalogViewLayout layout;
  final ValueChanged<CatalogItemEntity>? onItemTap;
  final CatalogItemCardBuilder? itemBuilder;

  final EdgeInsetsGeometry? padding;
  final double spacing;
  final int crossAxisCount;
  final double childAspectRatio;

  const GroupCatalogView({
    super.key,
    required this.groupId,
    this.layout = GroupCatalogViewLayout.list,
    this.onItemTap,
    this.itemBuilder,
    this.padding,
    this.spacing = 8,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.2,
  }) : assert(crossAxisCount > 0);

  @override
  State<GroupCatalogView> createState() => _GroupCatalogViewState();
}

class _GroupCatalogViewState extends State<GroupCatalogView> {
  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void didUpdateWidget(covariant GroupCatalogView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.groupId != widget.groupId) {
      _loadItems();
    }
  }

  void _loadItems() {
    context.read<CatalogCubit>().loadGroupItems(widget.groupId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogCubit, CatalogState>(
      builder: (context, state) {
        final groupState =
            state.catalogByGroupId[widget.groupId] ?? GroupCatalogState();

        return AppStateView<GroupCatalogState>(
          state: groupState,
          isEmpty: groupState.items.isEmpty,
          onRetry: _loadItems,
          contentBuilder: (groupState) {
            switch (widget.layout) {
              case GroupCatalogViewLayout.list:
                return CatalogItemList(
                  items: groupState.items,
                  onItemTap: widget.onItemTap,
                  itemBuilder: widget.itemBuilder,
                  padding: widget.padding,
                  spacing: widget.spacing,
                );

              case GroupCatalogViewLayout.grid:
                return CatalogItemGrid(
                  items: groupState.items,
                  onItemTap: widget.onItemTap,
                  itemBuilder: widget.itemBuilder,
                  padding: widget.padding,
                  mainAxisSpacing: widget.spacing,
                  crossAxisSpacing: widget.spacing,
                  crossAxisCount: widget.crossAxisCount,
                  childAspectRatio: widget.childAspectRatio,
                );
            }
          },
        );
      },
    );
  }
}
