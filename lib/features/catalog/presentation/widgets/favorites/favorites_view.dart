import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/catalog_item_entity.dart';
import '../../components/common/state/app_state_view.dart';
import '../../controllers/favorites/favorites_cubit.dart';
import '../../controllers/favorites/favorites_state.dart';
import '../catalog_items/catalog_item_card.dart';
import '../catalog_items/catalog_item_grid.dart';
import '../catalog_items/catalog_item_list.dart';

enum FavoritesViewLayout { list, grid }

class FavoritesView extends StatefulWidget {
  final FavoritesViewLayout layout;
  final ValueChanged<CatalogItemEntity>? onItemTap;
  final CatalogItemCardBuilder? itemBuilder;

  final EdgeInsetsGeometry? padding;
  final double spacing;

  final int crossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  const FavoritesView({
    super.key,
    this.layout = FavoritesViewLayout.list,
    this.onItemTap,
    this.itemBuilder,
    this.padding,
    this.spacing = 8,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.2,
    this.crossAxisSpacing = 8,
    this.mainAxisSpacing = 8,
  });

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  @override
  void initState() {
    super.initState();
    // context.read<FavoritesCubit>().loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        return AppStateView<FavoritesState>(
          state: state,
          isEmpty: state.favoriteItems.isEmpty,
          onRetry: () => context.read<FavoritesCubit>().refreshFavorites(),
          contentBuilder: (state) => _buildContent(state.favoriteItems),
        );
      },
    );
  }

  Widget _buildContent(List<CatalogItemEntity> items) {
    switch (widget.layout) {
      case FavoritesViewLayout.list:
        return CatalogItemList(
          items: items,
          onItemTap: widget.onItemTap,
          itemBuilder: widget.itemBuilder,
          padding: widget.padding,
          spacing: widget.spacing,
        );

      case FavoritesViewLayout.grid:
        return CatalogItemGrid(
          items: items,
          onItemTap: widget.onItemTap,
          itemBuilder: widget.itemBuilder,
          padding: widget.padding,
          crossAxisCount: widget.crossAxisCount,
          childAspectRatio: widget.childAspectRatio,
          crossAxisSpacing: widget.crossAxisSpacing,
          mainAxisSpacing: widget.mainAxisSpacing,
        );
    }
  }
}
