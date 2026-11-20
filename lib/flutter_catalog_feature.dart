/// Public API for the reusable Flutter Catalog Feature.
///
/// Import this library from the host application instead of depending on
/// internal feature paths.
export 'features/catalog/di/injection_container.dart'
    show initCatalogDependencies;

export 'features/catalog/domain/entities/catalog_item_entity.dart';
export 'features/catalog/domain/entities/group_entity.dart';

export 'features/catalog/presentation/catalog_feature.dart';
export 'features/catalog/presentation/pages/catalog_item_details_page.dart';
export 'features/catalog/presentation/pages/catalog_page.dart';
export 'features/catalog/presentation/pages/favorites_page.dart';
export 'features/catalog/presentation/pages/group_catalog_page.dart';

export 'features/catalog/presentation/widgets/catalog_item_details/catalog_item_details_view.dart';
export 'features/catalog/presentation/widgets/catalog_items/catalog_item_card.dart'
    show CatalogItemCardBuilder;
export 'features/catalog/presentation/widgets/catalog_items/group_catalog_view.dart'
    show GroupCatalogView, GroupCatalogViewLayout;
export 'features/catalog/presentation/widgets/favorites/favorite_button.dart'
    show FavoriteButton, FavoriteButtonBuilder;
export 'features/catalog/presentation/widgets/favorites/favorites_view.dart'
    show FavoritesView, FavoritesViewLayout;
export 'features/catalog/presentation/widgets/groups/group_item.dart'
    show GroupItemBuilder;
export 'features/catalog/presentation/widgets/groups/groups_view.dart'
    show GroupsView, GroupsViewLayout;
