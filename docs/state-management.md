# State management

## 1. Approach

The feature uses Cubit from `flutter_bloc`. State transitions are explicit and are implemented with handwritten Dart state classes and `copyWith` methods. The current design does not use Freezed or Equatable for state generation/equality.

The intent is to keep controller responsibilities page-sized or feature-sized, preserve predictable state transitions, and avoid introducing another abstraction unless a real requirement calls for it.

## 2. Shared load-state fields

Load-oriented states inherit common fields from `BaseLoadState`:

```dart
abstract class BaseLoadState {
  final bool hasLoaded;
  final bool isLoading;
  final bool isRefreshing;
  final Failure? failure;

  const BaseLoadState({
    this.hasLoaded = false,
    this.isLoading = false,
    this.isRefreshing = false,
    this.failure,
  });
}
```

The fields have distinct meanings:

| Field | Meaning |
|---|---|
| `hasLoaded` | Whether a successful/usable load has occurred. |
| `isLoading` | A primary load is in progress, commonly before content is available. |
| `isRefreshing` | A refresh is in progress while existing content may remain visible. |
| `failure` | The failure associated with the current load/refresh state, if any. |

States should preserve useful existing content during refresh where the relevant flow supports it. Avoid replacing a populated screen with a full-page loader for every refresh.

## 3. Controller organization

The agreed structure keeps each state beside its Cubit rather than creating a separate global states directory:

```text
presentation/controllers/
├── base/
│   └── base_load_state.dart
├── catalog/
│   ├── catalog_cubit.dart
│   └── catalog_state.dart
├── catalog_item_details/
│   ├── catalog_item_details_cubit.dart
│   └── catalog_item_details_state.dart
└── favorites/
    ├── favorites_cubit.dart
    └── favorites_state.dart
```

The exact filenames should follow the source tree if it has since been reorganized; the organizational rule is that a controller and its state stay together.

## 4. CatalogCubit

`CatalogCubit` owns catalog-level loading and grouped catalog content.

The agreed state shape includes:

- The list of groups.
- A map of catalog content keyed by group identifier (`catalogByGroupId`).
- Per-group loading state represented by `GroupCatalogState`.

`GroupCatalogState` carries the state and items for a particular group, allowing one group's items to load independently from another group's items. This avoids coupling all group-content loading to a single global loading flag.

The catalog controller coordinates the operations needed to load the groups and the items for a selected group. It should expose the relevant error/loading state to presentation rather than allowing widgets to call repositories directly.

## 5. FavoritesCubit

`FavoritesCubit` is scoped to a `userId`. Its state includes:

- `favoriteItems`: the user's loaded favorite catalog items.
- `favoriteItemIds`: an identifier set/list used for efficient favorite checks.
- `updatingItemIds`: identifiers of items whose favorite operation is in progress.

The state exposes helpers such as `isFavorite` and `isUpdating` so widgets do not need to recreate favorite lookup logic.

The Cubit loads favorites through `GetFavoriteCatalogItemsUseCase`. It supports the local-first/refresh behavior agreed for the feature. A favorite action should mark the affected item as updating, invoke the appropriate use case/repository operation, and then emit the resulting state. Failures should clear the updating marker and remain observable without losing unrelated favorites.

The exact optimistic-update and rollback behavior must match the current Cubit implementation; do not assume an optimistic UI update if the controller has not implemented it.

## 6. CatalogItemDetailsCubit

`CatalogItemDetailsCubit` owns the details state for one catalog item. Its state includes a nullable `CatalogItemEntity` while the item is being loaded or when no usable result is available.

The Cubit is created with an `itemId` through GetIt's parameterized factory. The details page/view initiates the item load as part of its lifecycle. The details controller should not be shared across different item IDs.

## 7. Cubit/provider scope

`CatalogFeature` is the composition boundary for shared controllers. Its provider tree supplies:

- `CatalogCubit` for catalog and group content.
- `FavoritesCubit` for the current `userId`.

The host should wrap its `MaterialApp` with `CatalogFeature`, ensuring that routes pushed by the host navigator can access these providers.

`CatalogItemDetailsCubit` is created per details page using the selected item's identifier. Avoid moving it into the global feature provider unless the lifecycle requirements change.

## 8. Widget subscriptions

Widgets should subscribe only to the state they need. For example, `FavoriteButton` uses `BlocSelector` to select the pair `{isFavorite, isUpdating}` for its item. This limits rebuilds to changes relevant to that button rather than rebuilding every button whenever an unrelated favorite changes.

The customizable favorite button builder has the agreed signature:

```dart
typedef FavoriteButtonBuilder = Widget Function(
  BuildContext context,
  bool isFavorite,
  bool isUpdating,
  VoidCallback onPressed,
);
```

## 9. Shared view states

Reusable state widgets are kept separate:

- `LoadingView`
- `EmptyView`
- `ErrorView`
- `AppStateView`

`AppStateView` composes the appropriate loading, empty, and error presentation based on the supplied state. Keeping these widgets separate allows the feature to reuse state presentation across regular and sliver-based layouts later without coupling the logic to one list implementation.

## 10. State-management rules

- Keep state immutable; create updated values rather than mutating existing collections.
- Keep each Cubit focused on a clear feature or page responsibility.
- Keep repository and use-case calls out of widgets.
- Use `BlocSelector` where a small part of a larger state is all a widget needs.
- Distinguish initial loading from refreshing existing content.
- Track item-level updates by identifier where concurrent item actions are possible.
- Close streams/subscriptions and dispose resources owned by a Cubit.
- Avoid timer-based work unless its lifecycle and cancellation are explicitly managed.
