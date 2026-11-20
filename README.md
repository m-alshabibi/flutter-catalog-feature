# Flutter Catalog Feature

**A reusable, offline-capable catalog feature module for Flutter applications.**

Flutter Catalog Feature is a self-contained feature module for applications that need to present a catalog of groups and catalog items, show item details, and let users manage their favorites. It is designed to be integrated into an existing Flutter application rather than to act as a complete end-user product.

The repository uses a Flutter package structure to make the feature easy to develop, test, version, and integrate. That packaging choice does not change the product's identity: the deliverable is a reusable feature module. The `example/` directory is a small host application demonstrating integration; it is not the feature's primary product.

> **Project status:** This documentation reflects the architecture and implementation decisions recorded during development. It distinguishes current implementation from deferred or future work. Verify the relevant code and run the checks in [Testing](docs/testing.md) before publishing a release.

## What the feature provides

- Displays catalog groups and the catalog items that belong to each group.
- Displays an item's details, including its long description and image gallery.
- Lets the host application provide the current user's identifier so favorites remain user-specific.
- Supports local persistence with Drift and remote communication through Dio.
- Uses a local-first approach so locally available catalog data and favorites can remain accessible when connectivity is unavailable.
- Exposes pages and reusable widgets while leaving app-level navigation and host-specific behavior to the integrating application.

The catalog content is managed externally. This feature does not provide an administration dashboard or content-authoring interface. It also does not implement authentication: the host application supplies the authenticated user's `userId`.

## Core concepts

| Concept | Responsibility |
|---|---|
| `GroupEntity` | Represents a catalog group. |
| `CatalogItemEntity` | Represents an item belonging to one group through `groupId`. |
| `FavoriteEntity` | Represents a user's favorite relationship to a catalog item. |
| `CatalogFeature` | Provides the shared catalog and favorites Cubits to the feature's widget subtree. |
| Host application | Owns authentication, app-level navigation, user context, and host-specific actions. |

Favorites are deliberately modeled separately from catalog items. A catalog item is content; whether it is a favorite depends on the current user.

## Architecture

The feature follows Clean Architecture and separates presentation, domain, and data concerns.

```text
lib/
└── features
    └───catalog/
        ├───data/
        │   ├───datasources/
        │   │   ├───local/
        │   │   │   └───database/
        │   │   │       └───tables/
        │   │   └───remote/
        │   ├───mapper/
        │   ├───models/
        │   └───repositories/
        ├───domain/
        │   ├───entities/
        │   ├───models/
        │   ├───repositories/
        │   └───usecases/
        └───presentation/
            ├───components/
            │   ├───common/
            │   └───layout/
            ├───controllers/
            │   ├───base/
            │   ├───catalog/
            │   ├───catalog_item_details/
            │   └───favorites/
            ├───pages/
            ├───scopes/
            └───widgets/
                ├───catalog_items/
                ├───catalog_item_details/
                ├───favorites/
                └───groups/
        ├───di/
        └───common/

```

- **Presentation** contains pages, reusable widgets, Cubits, and their states.
- **Domain** contains entities, repository contracts, and use cases. It does not depend on Flutter widgets or data-layer implementations.
- **Data** contains local and remote data sources, data models, and repository implementations.
- **DI** configures the feature's dependencies for the host application's `GetIt` container.

See [Architecture](docs/architecture.md) for the dependency rules and component responsibilities.

## Main technologies

| Concern | Technology / approach |
|---|---|
| UI | Flutter |
| State management | `flutter_bloc` Cubit |
| Dependency injection | GetIt |
| Local database | Drift |
| HTTP client | Dio |
| Connectivity abstraction | `connectivity_plus` through `NetworkInfo` |
| Result and error handling | `Result<T>` and failure types |

The project intentionally uses handwritten state classes and `copyWith` rather than introducing code-generation-based state libraries for this feature.

## Repository layout

```text
flutter-catalog-feature/
├── lib/                  # Reusable feature module
├── test/                 # Package and feature tests
├── example/              # Small host application demonstrating integration
├── docs/                 # Architecture, behavior, and integration documentation
├── analysis_options.yaml
├── pubspec.yaml
└── README.md
```

The exact set of platform folders under `example/` depends on the platforms generated for the host application.

## Run the example

From the repository root:

```bash
cd example
flutter pub get
flutter run
```

For a web run, use a browser device supported by the local Flutter installation:

```bash
flutter run -d chrome
```

The example configures the API root and demo user through Dart environment declarations. They can be overridden at run time:

```bash
flutter run \
  --dart-define=API_BASE_URL=http://localhost:8000 \
  --dart-define=DEMO_USER_ID=demo-user-1
```

The configured API URL must point to a reachable API implementation compatible with the feature's remote data sources. The project has used a FastAPI mock API during development; its endpoint contract should be kept in sync with the remote data sources.

For web builds, make sure the Drift web worker and SQLite WebAssembly assets referenced by the project's `DriftWebOptions` are available from the web application's asset root. See [Data layer](docs/data-layer.md).

## Integrate into another Flutter application

The feature is intended to be included in an existing host application. During local development, a path dependency can be used:

```yaml
dependencies:
  flutter_catalog_feature:
    path: ../flutter-catalog-feature
```

Initialize the feature's dependencies, then place `CatalogFeature` above the host application's `MaterialApp` so its providers remain available to routes pushed by the host navigator:

```dart
final getIt = GetIt.instance;

initCatalogDependencies(
  getIt: getIt,
  baseUrl: apiBaseUrl,
);

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

The snippet is illustrative: `openGroup` and `currentUserId` are owned by the host application, and imports should match the package's public API. The host application also owns navigation from a group to its items, from an item to its details, and any action that should open a host-specific screen.

See [Integration guide](docs/integration-guide.md) for the full setup and lifecycle guidance.

## Documentation

- [Documentation index](docs/README.md)
- [Architecture](docs/architecture.md)
- [Data layer](docs/data-layer.md)
- [State management](docs/state-management.md)
- [Application flows](docs/application-flows.md)
- [Integration guide](docs/integration-guide.md)
- [Testing](docs/testing.md)
- [Architecture decisions](docs/architecture-decisions.md)
- [Roadmap and known limitations](docs/roadmap.md)

## Design principles

1. **Feature ownership:** catalog behavior belongs to the catalog feature; app-level concerns remain in the host application.
2. **Dependency direction:** domain rules do not depend on Flutter, Drift, Dio, or GetIt.
3. **Offline capability:** local persistence is a first-class part of data access, not an afterthought.
4. **User-specific favorites:** favorite state is modeled as a relationship associated with `userId`.
5. **Explicit state:** loading, refreshing, and failure states are represented explicitly.
6. **Purposeful complexity:** technologies and abstractions are introduced to solve a real requirement, not merely to enlarge the stack.

## Scope boundaries

This repository is not intended to include:

- Authentication or session management.
- An admin dashboard or catalog content-authoring workflow.
- A complete production backend.
- A general-purpose pagination framework at this stage.
- A promise of background synchronization independent of the host application's lifecycle.

These boundaries are intentional and are described in more detail in [Architecture decisions](docs/architecture-decisions.md) and the [Roadmap](docs/roadmap.md).
