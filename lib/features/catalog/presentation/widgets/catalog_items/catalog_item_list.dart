import 'package:flutter/material.dart';

import '../../../../../core/presentation/widgets/app_list_view.dart';
import '../../../domain/entities/catalog_item_entity.dart';
import 'catalog_item_card.dart';

class CatalogItemList extends StatelessWidget {
  final List<CatalogItemEntity> items;
  final ValueChanged<CatalogItemEntity>? onItemTap;
  final CatalogItemCardBuilder? itemBuilder;

  final Axis scrollDirection;
  final EdgeInsetsGeometry? padding;
  final double spacing;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const CatalogItemList({
    super.key,
    required this.items,
    this.onItemTap,
    this.itemBuilder,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.spacing = 8,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return AppListView<CatalogItemEntity>(
      items: items,
      onItemTap: onItemTap,
      scrollDirection: scrollDirection,
      padding: padding,
      spacing: spacing,
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
