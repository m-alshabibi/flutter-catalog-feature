import 'package:flutter/material.dart';

import '../../domain/entities/catalog_item_entity.dart';
import '../widgets/favorites/favorites_view.dart';

class FavoritesPage extends StatelessWidget {
  /// Navigation is delegated to the host application.
  final ValueChanged<CatalogItemEntity> onItemTap;

  const FavoritesPage({super.key, required this.onItemTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: FavoritesView(onItemTap: onItemTap),
    );
  }
}
