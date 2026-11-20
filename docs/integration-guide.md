# Integration guide

## 1. Integration model

Flutter Catalog Feature is designed to be embedded in an existing Flutter application. The host application remains responsible for authentication, user identity, app-level navigation, app-wide configuration, and host-specific destinations.

The recommended integration model is:

```text
Host application
├── Authentication / current user
├── App navigation and shell
├── App configuration (API environment)
└── CatalogFeature
    ├── Catalog page
    ├── Group catalog page
    ├── Item details page
    └── Favorites page
```

## 2. Add the dependency

During local development, the host can depend on the feature through a path dependency:

```yaml
dependencies:
  flutter_catalog_feature:
    path: ../flutter-catalog-feature
```

The relative path must point from the host application's directory to the feature package. A Git dependency or a published package can be considered later if the project adopts a release/versioning workflow.

Then resolve packages:

```bash
flutter pub get
```

## 3. Initialize dependencies

The feature exposes an initialization function that accepts the host's GetIt container and the API root URL:

```dart
initCatalogDependencies(
  getIt: getIt,
  baseUrl: apiBaseUrl,
);
```

A typical host setup is:

```dart
import 'package:get_it/get_it.dart';
import 'package:flutter_catalog_feature/features/catalog/di/injection_container.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  initCatalogDependencies(
    getIt: getIt,
    baseUrl: apiBaseUrl,
  );
}
```

Call feature initialization once for the relevant service-container lifecycle. If the host already registered shared core dependencies, the feature's registration logic should preserve those instances where its “register if absent” behavior applies.

The API base URL is the root endpoint used to configure the Dio client. Do not hard-code environment-specific URLs inside feature repositories.

## 4. Provide the current user

The host supplies a stable user identifier for the active session:

```dart
final String currentUserId = authSession.userId;
```

The example can use a fixed demo identifier, but a real host should obtain the identifier from its own authentication/session layer. Do not pass passwords, tokens, or other credentials as `userId`.

The favorites controller is parameterized by this identifier. When the active account changes, recreate the user-scoped feature boundary so favorite state cannot leak between users.

## 5. Place CatalogFeature above MaterialApp

Wrap the host's `MaterialApp` with `CatalogFeature`:

```dart
runApp(
  CatalogFeature(
    getIt: getIt,
    userId: currentUserId,
    child: MaterialApp(
      home: CatalogPage(
        onGroupTap: openGroup,
      ),
    ),
  ),
);
```

This provider placement is important. The `CatalogFeature` providers should remain ancestors of routes pushed by the host navigator. Placing the feature only inside one route can make its Cubits unavailable to pages created outside that route's subtree.

## 6. Own navigation in the host

The feature exposes pages and callbacks; the host decides how to navigate. The conceptual flow is:

```dart
void openGroup(GroupEntity group) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => GroupCatalogPage(
        group: group,
        onItemTap: openItem,
      ),
    ),
  );
}

void openItem(CatalogItemEntity item) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => CatalogItemDetailsPage(
        getIt: getIt,
        itemId: item.id,
        onOpenItem: handleOpenItem,
      ),
    ),
  );
}
```

The exact constructor parameters should match the current public page APIs. The host can use named routes, Router API, or a routing package instead of `MaterialPageRoute`; the feature does not require a specific navigation mechanism.

The host also decides what the details view's `onOpenItem` callback should do. It may open a host-owned route, show a dialog, or trigger another application-specific action.

## 7. Use the favorites page

The favorites page uses the `FavoritesCubit` already provided by `CatalogFeature`:

```dart
FavoritesPage(
  onItemTap: openItem,
)
```

Do not create a second favorites controller at the page level unless deliberately replacing the shared feature scope. The feature boundary owns the initial favorites load; the view should consume the state.

## 8. Use reusable views and widgets

The feature includes reusable presentation pieces for common catalog layouts, including list/grid variants and shared loading/empty/error views. Prefer using the public widget APIs rather than copying feature internals into the host. The host can still provide callbacks and supported builders to adapt item interactions and presentation.

The favorite button supports a custom builder through the agreed `FavoriteButtonBuilder` callback when a host or feature screen needs a different visual representation.

## 9. Web integration

When the host targets Web, include the Drift static assets expected by the feature's configured `DriftWebOptions`. In the demo host these files belong under the web application's served asset root. Confirm the exact asset paths and compatible versions against the project's Drift setup before deployment.

## 10. Integration checklist

- [ ] Add the feature dependency and run `flutter pub get`.
- [ ] Configure the API base URL for the target environment.
- [ ] Initialize the feature's GetIt registrations once.
- [ ] Obtain the current `userId` from the host's authentication/session layer.
- [ ] Wrap `MaterialApp` with `CatalogFeature`.
- [ ] Wire group and item callbacks to host-owned navigation.
- [ ] Decide what the item details `onOpenItem` callback should do.
- [ ] Include the required Drift Web assets when targeting Web.
- [ ] Verify that account changes recreate the user-scoped favorites state.
- [ ] Run the host's analysis, unit, widget, and platform smoke checks.
