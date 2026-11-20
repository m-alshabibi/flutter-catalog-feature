import 'package:flutter/material.dart';

import 'app_list_view.dart';

class AppGridView<T> extends StatelessWidget {
  final List<T> items;
  final AppListItemBuilder<T> itemBuilder;
  final ValueChanged<T>? onItemTap;

  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const AppGridView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onItemTap,
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
    return GridView.builder(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final child = itemBuilder(context, item);

        if (onItemTap == null) return child;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onItemTap!(item),
          child: child,
        );
      },
    );
  }
}
