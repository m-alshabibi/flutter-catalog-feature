# Architecture

## 1. Architectural goal

Flutter Catalog Feature is a reusable feature module that can be embedded in a Flutter host application. It is structured as a Flutter package so that the feature can be developed and integrated independently, while the example application demonstrates how a host app consumes it.

The module follows Clean Architecture. The purpose is to keep business rules independent from UI and infrastructure, make data sources replaceable, and give the host application a clear integration boundary.

## 2. High-level structure

```text
Catalog Feature
│
├── Presentation
│   ├── Pages
│   ├── Widgets
│   └── Controllers (Cubits + States)
│
├── Domain
│   ├── Entities
│   ├── Repository contracts
│   └── Use cases
│
├── Data
│   ├── Local data sources (Drift)
│   ├── Remote data sources (Dio)
│   ├── Models
│   └── Repository implementations
│
└── Dependency injection
```

### Dependency direction

```text
Presentation ───────► Domain ◄─────── Data
       │                                │
       └──── uses domain contracts       └──── implements domain contracts

DI assembles the concrete implementations and presentation controllers.
```

The domain layer must not import presentation, Drift, Dio, or GetIt implementation details. Data-layer implementations depend on domain contracts. Presentation depends on domain abstractions and use cases rather than directly querying database tables or making HTTP requests.

## 3. Layer responsibilities

### Presentation

Presentation is responsible for rendering the catalog experience and translating user interactions into use-case calls.

Its main areas are:

- **Pages:** page-level compositions such as the catalog, group catalog, item details, and favorites pages.
- **Widgets:** reusable UI pieces such as group and item lists/grids, item cards, favorite controls, and shared loading/empty/error views.
- **Controllers:** Cubits and their state classes. Each controller owns the state transitions for a page-sized or feature-sized concern.

Presentation does not own authentication, persistent storage, HTTP configuration, or the host application's navigation policy.

### Domain

Domain contains the business concepts and operations of the feature:

- `GroupEntity`
- `CatalogItemEntity`
- `FavoriteEntity`
- Repository interfaces
- Use cases
- Shared result and failure contracts

Domain types should remain usable without a Flutter widget tree or a concrete database/network implementation.

### Data

Data implements domain repository contracts. It coordinates local and remote data sources, maps persistence/transport models to domain entities, and translates infrastructure errors into the feature's failure model.

The local database is implemented with Drift. Remote requests use Dio. Connectivity is abstracted through `NetworkInfo` backed by `connectivity_plus`.

### Dependency injection

Feature dependencies are registered under `features/catalog/di/`. The host application passes its `GetIt` instance and the API `baseUrl` to the feature's initialization function. This keeps dependency setup explicit and allows the host to choose the API environment.

## 4. Domain model

### GroupEntity

A group represents a category or section in the catalog. The agreed fields are:

| Field | Meaning |
|---|---|
| `id` | Stable group identifier. |
| `name` | Display name. |
| `description` | Optional explanatory text. |
| `imageUrl` | Optional group image. |
| `sortOrder` | Display ordering; defaults to `0`. |
| `isActive` | Whether the group is active; defaults to `true`. |
| `createdAt` | Creation timestamp. |
| `updatedAt` | Last update timestamp. |

### CatalogItemEntity

A catalog item belongs to exactly one group through `groupId` (one-to-many relationship from group to items).

| Field | Meaning |
|---|---|
| `id` | Stable item identifier. |
| `groupId` | Identifier of the owning group. |
| `name` | Item name. |
| `shortDescription` | Optional concise text for list/card presentation. |
| `longDescription` | Optional detailed text for the details view. |
| `imageUrl` | Optional primary image. |
| `gallery` | Additional image references; defaults to an empty list. |
| `sortOrder` | Display ordering; defaults to `0`. |
| `isActive` | Whether the item is active; defaults to `true`. |
| `isFeatured` | Whether the item is highlighted; defaults to `false`. |
| `metadata` | Optional additional structured data. |
| `createdAt` | Creation timestamp. |
| `updatedAt` | Last update timestamp. |

### FavoriteEntity

A favorite represents a relationship between a user and a catalog item. Its agreed fields are `id`, `userId`, and `catalogItemId`. Favorite status is not embedded in `CatalogItemEntity`, because it varies by user.

### BaseEntity

The shared base entity was agreed to provide `id`, `createdAt`, and `updatedAt`. The established behavior is:

- Empty identifiers are rejected with `ArgumentError`.
- Equality is based on the runtime type and `id`.
- `createdAt` and `updatedAt` are late-initialized fields in the current design.

Any change to these rules should be reflected in entity tests and this document.

## 5. Relationship model

```text
GroupEntity 1 ───────── * CatalogItemEntity

User 1 ───────── * FavoriteEntity * ───────── 1 CatalogItemEntity
```

The user/account model belongs to the host application. The feature receives a `userId`; it does not own the user's identity or credentials.

## 6. Presentation composition

The feature exposes pages and reusable views rather than forcing a complete app shell on the host. The host decides how and when to navigate between:

- Catalog page
- Group catalog page
- Catalog item details page
- Favorites page

Callbacks are used for host-specific actions, including opening an item in a host-owned destination. The feature does not assume a particular route naming scheme or navigation package.

## 7. Provider and lifecycle boundary

`CatalogFeature` provides the shared `CatalogCubit` and user-scoped `FavoritesCubit` to its child widget tree. It should wrap the host's `MaterialApp` so that routes created by the host navigator remain below the providers in the widget tree.

The item details controller is item-specific and is created with the selected `itemId` through GetIt's parameterized factory registration. Its lifecycle is scoped to the details page/controller owner.

## 8. Dependency registration

The agreed initialization entry point is:

```dart
initCatalogDependencies({
  required GetIt getIt,
  required String baseUrl,
});
```

The feature registers its concrete data dependencies, repositories, use cases, and controllers. Core dependencies that may be shared with the host are registered only when absent, so the host can supply an existing instance where appropriate.

The current controller registration strategy is:

| Controller | Registration lifetime |
|---|---|
| `CatalogCubit` | Factory |
| `FavoritesCubit` | Parameterized factory using `userId` |
| `CatalogItemDetailsCubit` | Parameterized factory using `itemId` |

## 9. Design boundaries

The following are intentionally outside this feature:

- Authentication and session management.
- Admin tools and content authoring.
- Host application navigation policy.
- Host-specific design system and branding.
- A production backend deployment and operational environment.

These boundaries keep the module focused and reusable.
