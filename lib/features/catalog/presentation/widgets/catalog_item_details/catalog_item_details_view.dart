import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/catalog_item_entity.dart';
import '../../components/common/state/app_state_view.dart';
import '../../controllers/catalog_item_details/catalog_item_details_cubit.dart';
import '../../controllers/catalog_item_details/catalog_item_details_state.dart';

class CatalogItemDetailsView extends StatefulWidget {
  final ValueChanged<CatalogItemEntity>? onOpenItem;

  const CatalogItemDetailsView({super.key, this.onOpenItem});

  @override
  State<CatalogItemDetailsView> createState() => _CatalogItemDetailsViewState();
}

class _CatalogItemDetailsViewState extends State<CatalogItemDetailsView> {
  @override
  void initState() {
    super.initState();
    context.read<CatalogItemDetailsCubit>().loadItem();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogItemDetailsCubit, CatalogItemDetailsState>(
      builder: (context, state) {
        return AppStateView<CatalogItemDetailsState>(
          state: state,
          isEmpty: state.item == null,
          onRetry: () {
            context.read<CatalogItemDetailsCubit>().retryLoadItem();
          },
          contentBuilder: (state) {
            final item = state.item!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.imageUrl != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        item.imageUrl!,
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox(
                          height: 220,
                          child: Center(
                            child: Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (item.longDescription != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      item.longDescription!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                  // FavoriteButton(itemId: item.id),
                  // FavoriteButton(itemId: item.id),
                  if (item.gallery.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Gallery',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: item.gallery.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.gallery[index],
                              width: 140,
                              height: 110,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const SizedBox(
                                width: 140,
                                child: Center(
                                  child: Icon(Icons.broken_image_outlined),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  if (widget.onOpenItem != null) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => widget.onOpenItem!(item),
                        child: const Text('Open item'),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}
