import 'package:flutter/material.dart';

typedef AppListItemBuilder<T> = Widget Function(BuildContext context, T item);

class AppListView<T> extends StatelessWidget {
  final List<T> items;
  final AppListItemBuilder<T> itemBuilder;
  final ValueChanged<T>? onItemTap;

  final Axis scrollDirection;
  final EdgeInsetsGeometry? padding;
  final double spacing;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const AppListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onItemTap,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.spacing = 8,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: scrollDirection,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: items.length,
      separatorBuilder: (_, _) => SizedBox(
        width: scrollDirection == Axis.horizontal ? spacing : 0,
        height: scrollDirection == Axis.vertical ? spacing : 0,
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
