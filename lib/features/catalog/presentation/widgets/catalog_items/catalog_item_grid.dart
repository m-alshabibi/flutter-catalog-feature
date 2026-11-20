import 'package:flutter/material.dart';

import '../../../../../core/presentation/widgets/app_grid_view.dart';
import '../../../domain/entities/catalog_item_entity.dart';
import 'catalog_item_card.dart';

class CatalogItemGrid extends StatelessWidget {
  final List<CatalogItemEntity> items;
  final ValueChanged<CatalogItemEntity>? onItemTap;
  final CatalogItemCardBuilder? itemBuilder;

  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const CatalogItemGrid({
    super.key,
    required this.items,
    this.onItemTap,
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
    return AppGridView<CatalogItemEntity>(
      items: items,
      onItemTap: onItemTap,
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      childAspectRatio: childAspectRatio,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemBuilder: (context, item) {
        return itemBuilder?.call(context, item) ??
            CatalogItemCard(
              item: item,
              onTap: onItemTap == null ? null : () => onItemTap!(item),
              builder: itemBuilder,
            );
      },
    );
  }
}
