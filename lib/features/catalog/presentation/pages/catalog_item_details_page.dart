import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../domain/entities/catalog_item_entity.dart';
import '../controllers/catalog_item_details/catalog_item_details_cubit.dart';
import '../widgets/catalog_item_details/catalog_item_details_view.dart';

class CatalogItemDetailsPage extends StatelessWidget {
  final GetIt getIt;
  final String itemId;
  final ValueChanged<CatalogItemEntity> onOpenItem;

  const CatalogItemDetailsPage({
    super.key,
    required this.getIt,
    required this.itemId,
    required this.onOpenItem,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CatalogItemDetailsCubit>(
      create: (_) => getIt<CatalogItemDetailsCubit>(param1: itemId),
      child: Scaffold(
        appBar: AppBar(title: const Text('Item Details')),
        body: CatalogItemDetailsView(onOpenItem: onOpenItem),
      ),
    );
  }
}
