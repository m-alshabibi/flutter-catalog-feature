import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'features/catalog/domain/entities/catalog_item_entity.dart';
import 'features/catalog/domain/entities/group_entity.dart';
import 'features/catalog/presentation/catalog_feature.dart';
import 'features/catalog/presentation/pages/catalog_item_details_page.dart';
import 'features/catalog/presentation/pages/catalog_page.dart';
import 'features/catalog/presentation/pages/favorites_page.dart';
import 'features/catalog/presentation/pages/group_catalog_page.dart';

class DemoApp extends StatelessWidget {
  final GetIt getIt;
  final String userId;

  const DemoApp({super.key, required this.getIt, required this.userId});

  @override
  Widget build(BuildContext context) {
    return CatalogFeature(
      getIt: getIt,
      userId: userId,
      child: MaterialApp(
        title: 'Catalog Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),
        home: DemoHomePage(getIt: getIt),
      ),
    );
  }
}

class DemoHomePage extends StatefulWidget {
  final GetIt getIt;

  const DemoHomePage({super.key, required this.getIt});

  @override
  State<DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<DemoHomePage> {
  int _selectedIndex = 0;

  void _openGroup(GroupEntity group) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GroupCatalogPage(group: group, onItemTap: _openItem),
      ),
    );
  }

  void _openItem(CatalogItemEntity item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CatalogItemDetailsPage(
          getIt: widget.getIt,
          itemId: item.id,
          onOpenItem: _onOpenItem,
        ),
      ),
    );
  }

  void _onOpenItem(CatalogItemEntity item) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Open item: ${item.name}')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          CatalogPage(onGroupTap: _openGroup),
          FavoritesPage(onItemTap: _openItem),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.grid_view), label: 'Catalog'),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
