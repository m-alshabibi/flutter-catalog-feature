import 'package:flutter/material.dart';

import '../../../domain/entities/catalog_item_entity.dart';

typedef CatalogItemCardBuilder = Widget Function(
  BuildContext context,
  CatalogItemEntity item,
);

class CatalogItemCard extends StatelessWidget {
  final CatalogItemEntity item;
  final VoidCallback? onTap;
  final CatalogItemCardBuilder? builder;

  const CatalogItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.builder,
  });

  @override
  Widget build(BuildContext context) {
    if (builder != null) {
      return builder!(context, item);
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.imageUrl != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  item.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const Center(child: Icon(Icons.broken_image_outlined)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (item.shortDescription != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.shortDescription!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
