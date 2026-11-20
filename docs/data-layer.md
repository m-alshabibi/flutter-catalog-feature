# Data layer

## 1. Purpose

The data layer provides the persistence and remote communication required by the catalog feature. It implements domain repository contracts and hides database/HTTP details from the domain and presentation layers.

The selected approach is offline-capable and local-first: local persistence is available to support reads and user actions when the network is unavailable, while remote data sources provide server-backed catalog content and synchronization opportunities.

## 2. Components

| Component | Responsibility |
|---|---|
| Local data sources | Read and write persisted catalog and favorite records. |
| Remote data sources | Retrieve or update server-backed records through HTTP. |
| Data models | Convert database/API representations to domain entities and vice versa. |
| Repository implementations | Coordinate data sources and implement domain contracts. |
| `DioClient` / Dio configuration | Provide the configured HTTP client. |
| `NetworkInfo` | Abstract connectivity checks through `connectivity_plus`. |
| Result/failure mapping | Return expected failures through the shared result contract. |

## 3. Local persistence with Drift

Drift is the local database layer. The agreed schema contains tables for:

- Groups
- Catalog items
- Favorites

The database schema version recorded during development is **2**. Schema changes must be accompanied by a schema-version update and the appropriate migration strategy; do not change the version number without reviewing existing installations and migration tests.

### Favorite synchronization metadata

The favorites table uses synchronization metadata:

- `isSynced` indicates whether the local favorite change has been synchronized.
- `isDeleted` acts as a deletion marker (tombstone) so a removal can still be communicated to the remote source during a later synchronization pass.

This design avoids requiring a separate synchronization table for the current favorite workflow.

The presence of these columns does not, by itself, mean that a complete background synchronization engine exists. Retry scheduling, background execution, and conflict resolution must be described as implemented only after their code paths are verified.

## 4. Remote communication with Dio

Remote data sources use Dio. The root API endpoint is injected through the feature's dependency initialization rather than being embedded in repository or data-source code.

```dart
initCatalogDependencies(
  getIt: getIt,
  baseUrl: apiBaseUrl,
);
```

This allows the host application to switch between development, staging, and production API environments without changing domain logic.

A FastAPI mock API was selected for development. The remote API contract must remain aligned with the actual remote data-source methods and serialization models. This document intentionally does not invent endpoint paths or request/response payloads that were not established in the recorded project decisions.

## 5. Offline-capable access strategy

The intended data access pattern is:

1. Read locally persisted data when available.
2. Present the local result without requiring a successful network request.
3. Attempt a remote refresh when the application/data flow requests one and connectivity allows it.
4. Persist successful remote results locally so later reads can use the cache.
5. Preserve locally created favorite changes while offline and mark them for synchronization.

The exact timing and retry policy belong to the repository/synchronization implementation. Avoid describing the feature as having guaranteed background sync unless a background worker or equivalent lifecycle-independent mechanism is implemented and tested.

## 6. Favorites data flow

`FavoriteRepository` returns `FavoriteEntity` records; it does not return catalog items. The use-case layer composes the two domain repositories when it needs the corresponding catalog content.

The agreed `GetFavoriteCatalogItemsUseCase` behavior is:

1. Accept a `userId`.
2. Fetch that user's `FavoriteEntity` records from `FavoriteRepository`.
3. Return an empty list immediately when no favorites exist.
4. Otherwise obtain the referenced catalog items through `CatalogItemRepository.getCatalogItemsByIds`.
5. Return `List<CatalogItemEntity>`.

This keeps the favorite relationship independent from catalog content and avoids duplicating `isFavorite` inside the catalog entity.

## 7. Catalog items with favorite status

`GetCatalogItemsWithFavoriteStatusUseCase` accepts a `userId` and returns:

```dart
Map<String, List<CatalogItemWithFavorite>>
```

The map is grouped by `groupId`. `CatalogItemWithFavorite` combines catalog item presentation data with the user's favorite status for use cases that need to render grouped catalog content with favorite indicators.

This is a derived result, not a reason to place user-specific favorite state on `CatalogItemEntity`.

## 8. Serialization and safe parsing

The project includes a `SafeJsonExtension` for guarded JSON value conversion. The recorded usage includes nullable date parsing such as:

```dart
json.asDateTimeNullable('createdAt')
json.asDateTimeNullable('updatedAt')
```

Keep parsing concerns in the data layer. Malformed or absent optional values should be handled deliberately and mapped into the expected domain representation or a typed failure; avoid leaking raw JSON parsing exceptions into presentation code.

## 9. Result and failure handling

Repository/use-case operations use the shared `Result<T>` and failure model (`FailureResult` and feature failure types) to represent expected success/failure outcomes.

Expected infrastructure failures—such as connectivity, server, database, or parsing failures—should be translated at the data boundary. Presentation controllers then convert the returned result into state without needing to know whether the failure originated in Dio or Drift.

Do not use thrown exceptions as the normal control-flow mechanism for expected repository failures. Programming errors and violated invariants may still require exceptions.

## 10. Connectivity

`NetworkInfo` abstracts the connectivity package. Repositories/data sources should depend on this abstraction rather than querying `connectivity_plus` directly from use cases or widgets.

Connectivity status is an indication of network availability, not proof that the configured API is reachable. Remote requests must still handle connection and server failures.

## 11. Drift on Web

The Web implementation requires the static assets referenced by the project's `DriftWebOptions`, including:

- `sqlite3.wasm`
- `drift_worker.dart.js`

Those assets must be served from the locations configured by the database setup and included in the host application's web output (for the demo, the `example/web/` asset root). Keep the filenames and configured paths in sync. Use the versions and setup instructions compatible with the Drift dependencies pinned by the project; do not copy arbitrary versions from unrelated examples.

## 12. Data-layer change checklist

When changing persistence or remote behavior:

- Update the domain repository contract if the business operation changes.
- Update local and remote data-source implementations as needed.
- Update mapping/serialization code.
- Add or update migration logic when the Drift schema changes.
- Update the database schema version when required.
- Cover behavior with repository/use-case tests.
- Update this document and the relevant architecture decision if the change affects the feature's guarantees.
