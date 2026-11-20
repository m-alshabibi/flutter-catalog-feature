# Architecture decisions

This document records the important decisions that shape Flutter Catalog Feature, including the reasoning and the trade-offs. It is intended to explain why the project is structured as it is, not to claim that every possible capability is already implemented.

## ADR-001 — Build a reusable feature module, not a complete application

**Status:** Accepted

**Decision:** The product is a focused catalog feature that can be embedded in an existing Flutter application. The repository uses a package structure to make the module independently manageable and reusable.

**Reasoning:** The portfolio goal is to demonstrate feature-level engineering: clear domain boundaries, offline-capable data access, state management, and a practical integration contract. Building a full commerce/catalog application would add unrelated scope.

**Trade-off:** The host application must provide app-level concerns such as authentication, navigation, and user context. The `example/` app demonstrates this integration but is not the primary product.

## ADR-002 — Use Clean Architecture boundaries

**Status:** Accepted

**Decision:** Separate presentation, domain, data, and feature dependency injection.

**Reasoning:** Business rules should not depend on Flutter widgets, Drift tables, Dio, or a service locator. Repository contracts in domain allow data implementations to change without rewriting use cases.

**Trade-off:** There is more structure than a single-screen prototype requires. The structure is justified by the feature's offline/remote behavior and portfolio emphasis on maintainable boundaries; it should not be expanded with abstractions that solve no current problem.

## ADR-003 — Support local-first, offline-capable data access

**Status:** Accepted

**Decision:** Use Drift for local persistence and Dio-backed remote data sources. Prefer locally available data for usable reads and refresh from the remote source through repository flows.

**Reasoning:** Catalog browsing and favorite interactions should remain useful when connectivity is unavailable or unreliable.

**Trade-off:** Cached data introduces consistency and synchronization concerns. The project records favorite synchronization state, but a complete background sync engine, retry scheduler, and conflict-resolution policy should not be claimed until implemented and tested.

## ADR-004 — Keep favorite relationships separate from catalog items

**Status:** Accepted

**Decision:** Model favorites with `FavoriteEntity` (`id`, `userId`, `catalogItemId`) rather than storing `isFavorite` on `CatalogItemEntity`.

**Reasoning:** Favorite status is user-specific. A single catalog item can be a favorite for one user and not another. Keeping the relationship separate avoids mixing global catalog content with per-user state.

**Trade-off:** A use case may need to combine catalog item data and favorite state for presentation. `GetCatalogItemsWithFavoriteStatusUseCase` provides this derived view grouped by `groupId`.

## ADR-005 — Use a one-to-many group/item relationship

**Status:** Accepted

**Decision:** Each `CatalogItemEntity` belongs to one group through `groupId`.

**Reasoning:** The current feature scope models a catalog item as belonging to a single catalog group. A many-to-many relationship would add join-table and assignment complexity without a confirmed requirement.

**Trade-off:** Reusing the same item in multiple groups would require a deliberate model/schema change later.

## ADR-006 — Use Cubit with handwritten state classes

**Status:** Accepted

**Decision:** Use Cubit and ordinary Dart state classes with `copyWith`; do not introduce Freezed or Equatable for the current implementation.

**Reasoning:** The feature's state models are manageable by hand, and the team can keep state behavior explicit without another code-generation dependency.

**Trade-off:** Equality and immutable collection handling must be implemented carefully. If state complexity grows substantially, the choice can be revisited based on concrete maintenance costs.

## ADR-007 — Share load-state fields through inheritance

**Status:** Accepted

**Decision:** Use `BaseLoadState` for common fields: `hasLoaded`, `isLoading`, `isRefreshing`, and `failure`.

**Reasoning:** Multiple controllers share the distinction between initial loading, refreshing existing data, and failure. A common base reduces repeated state fields and keeps those semantics consistent.

**Trade-off:** Inheritance should remain limited to genuinely shared load-state semantics; do not create a deep state hierarchy.

## ADR-008 — Use GetIt with feature-scoped registration

**Status:** Accepted

**Decision:** Register catalog dependencies under `features/catalog/di/` through an explicit initialization function that accepts `GetIt` and `baseUrl`.

**Reasoning:** The host application controls the container and API environment. Feature-specific registration stays near the feature instead of accumulating in a global application setup file.

**Trade-off:** The host must call initialization and keep its container lifecycle coherent. Core dependencies are registered only if absent where the current implementation supports host-provided instances.

## ADR-009 — Keep authentication outside the feature

**Status:** Accepted

**Decision:** Do not implement sign-in, sign-up, session management, or token ownership in this module. The host passes the current `userId`.

**Reasoning:** Authentication is unrelated to the catalog's core responsibility and would make the feature less reusable. User-specific favorites only require a stable user identifier at this boundary.

**Trade-off:** The host is responsible for providing the correct identity and recreating the user-scoped favorites state when the active account changes.

## ADR-010 — Keep content administration external

**Status:** Accepted

**Decision:** Do not add admin UI or user-created groups/items. Catalog content is managed by an external management system/API.

**Reasoning:** The feature is for consuming catalog content, not administering it. Adding an admin workflow would significantly expand the product scope.

**Trade-off:** Content creation and management must be handled elsewhere.

## ADR-011 — Defer a general pagination framework

**Status:** Deferred by design

**Decision:** Use the current catalog/group loading approach and avoid introducing a comprehensive generic pagination abstraction in the first version.

**Reasoning:** Loading behavior should meet the actual group/item UI needs without prematurely designing a reusable pagination engine. Per-group loading state already provides useful isolation.

**Trade-off:** If catalog sizes or backend constraints require more advanced paging, the data and state contracts may need to evolve.

## ADR-012 — Consider a lightweight list model and full details model later

**Status:** Future consideration

**Decision:** Keep the current `CatalogItemEntity` as the shared domain item model for now. Consider splitting list/card data from full details data only if measured payload or performance requirements justify it.

**Reasoning:** A smaller list model could reduce data transferred and held for large catalogs, while the details model could be fetched only when an item is opened.

**Trade-off:** Introducing separate models adds mapping, repository, and state complexity. It is not justified until the need is demonstrated.

## ADR-013 — Provide an example host application

**Status:** Accepted

**Decision:** Keep an `example/` application in the repository to demonstrate the feature integrated into a host app.

**Reasoning:** A reusable module is easier to evaluate when reviewers can see how dependencies are initialized, how the feature is mounted, and how host-owned navigation is wired.

**Trade-off:** The example must remain a thin integration shell rather than growing into a second product. Its presence does not imply that the project is an ordinary full application.
