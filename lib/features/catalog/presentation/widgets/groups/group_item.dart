import 'package:flutter/material.dart';

import '../../../domain/entities/group_entity.dart';

typedef GroupItemBuilder = Widget Function(
  BuildContext context,
  GroupEntity group,
);

class GroupItem extends StatelessWidget {
  final GroupEntity group;
  final VoidCallback? onTap;
  final GroupItemBuilder? builder;

  const GroupItem({super.key, required this.group, this.onTap, this.builder});

  @override
  Widget build(BuildContext context) {
    if (builder != null) {
      return builder!(context, group);
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (group.imageUrl != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  group.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const Center(child: Icon(Icons.broken_image)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (group.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      group.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
