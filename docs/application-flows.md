# Application flows

This document describes the intended user-facing flows and the responsibilities of the host application, presentation controllers, use cases, repositories, and data sources.

## 1. Application startup and feature scope

1. The host application initializes Flutter and its service container.
2. The host calls `initCatalogDependencies` with its GetIt instance and API base URL.
3. The host obtains the current user's identifier from its own authentication/session layer.
4. The host places `CatalogFeature` above its `MaterialApp`, passing `getIt`, `userId`, and the app widget tree.
5. `CatalogFeature` creates the shared catalog and user-scoped favorites controllers and starts their initial loading operations as configured by the feature.

The feature does not sign in the user or determine the current identity. A change of user must be reflected by rebuilding/recreating the user-scoped feature boundary with the correct `userId` and disposing the old scope appropriately.

## 2. Browse catalog groups

1. The host displays `CatalogPage`.
2. The page reads groups from `CatalogCubit`.
3. The catalog flow loads locally available data and performs the relevant remote refresh according to the repository strategy.
4. Presentation displays a loading state when no content is available yet, an empty state when there are no groups, or an error state when the operation fails without usable content.
5. When groups are available, the page displays them using the group presentation widgets.

The host supplies the group-tap callback and decides how to navigate to the selected group's catalog page.

## 3. Browse a group's catalog items

1. The user selects a group.
2. The host navigates to `GroupCatalogPage` and passes the selected `GroupEntity`.
3. `GroupCatalogView` requests the items for that group from `CatalogCubit`.
4. The controller stores the group's result under its `groupId` and exposes a `GroupCatalogState` for that group.
5. The view displays the group's items using the configured list or grid presentation.
6. Selecting an item invokes the host-provided callback.

Per-group state allows item loading to be independent between groups. The feature does not require the host to adopt a specific navigation package.

## 4. View item details

1. The host receives the selected `CatalogItemEntity` and opens the details page.
2. The host creates `CatalogItemDetailsPage` with the feature's GetIt instance and the item's `id`.
3. The page obtains a `CatalogItemDetailsCubit` using the parameterized `itemId` registration.
4. The details view initiates the details load.
5. The controller exposes loading, failure, and item data through `CatalogItemDetailsState`.
6. The view displays the long description, primary image, gallery, and favorite control where available.
7. The `onOpenItem` callback is delegated to the host when the user requests a host-specific action.

The feature provides the callback; the host decides what “open item” means in its own application.

## 5. View favorites

1. The host opens `FavoritesPage`.
2. The page reads the already-provided `FavoritesCubit`.
3. The Cubit loads the current user's favorites through `GetFavoriteCatalogItemsUseCase`.
4. The use case obtains favorite relationships and then resolves their catalog items.
5. The page displays the resulting items using the reusable catalog item list/grid widgets.
6. Selecting a favorite item invokes the host's item-navigation callback.

The feature boundary is responsible for initiating the initial favorites load. `FavoritesView` should render and react to state; it should not independently start a second initial load every time the view is built.

## 6. Add or remove a favorite

1. A favorite control determines the current state using `FavoritesCubit`.
2. The control prevents or indicates duplicate actions while the item identifier is in `updatingItemIds`.
3. The user action is sent to the favorites controller.
4. The controller invokes the relevant favorite operation.
5. The local favorite record is updated according to the offline-capable repository behavior. Synchronization metadata records whether the local change still needs to reach the remote service.
6. The controller emits the resulting favorite state and clears the item's updating marker.
7. `BlocSelector` rebuilds only the favorite control(s) whose selected values changed.

The exact rollback behavior after a failed write and the remote synchronization retry policy must be taken from the implementation. The metadata supports a future synchronization pass but is not proof of a background worker.

## 7. Offline and remote-refresh behavior

When offline:

- Locally persisted catalog content can be shown when it exists.
- Locally persisted favorite state remains available.
- Favorite changes are recorded locally with sync metadata.
- Remote refreshes can fail and should be represented through the feature's failure state without unnecessarily discarding usable cached content.

When connectivity returns, remote refresh or synchronization can proceed through the implemented repository/data-source path. Do not assume that every pending operation is automatically synchronized in the background unless that behavior is present and verified in the code.

## 8. Errors and empty results

The presentation layer should distinguish:

- Initial loading with no usable data.
- A successful empty result.
- A failure with no previously loaded data.
- A refresh failure while previously loaded content remains available.

The shared `AppStateView` and related loading/empty/error widgets provide consistent presentation for these states.

## 9. Ownership summary

| Concern | Owner |
|---|---|
| User identity and authentication | Host application |
| API base URL / environment | Host application configuration, passed to feature DI |
| Data retrieval and persistence | Feature data layer |
| Catalog and favorite state | Feature Cubits |
| Page composition and reusable catalog UI | Feature presentation layer |
| App-level routes and destination behavior | Host application |
| Catalog content administration | External management system, outside this feature |
