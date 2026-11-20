# Roadmap and known limitations

This roadmap separates the current feature scope from improvements that may be useful later. Items listed as future work are not promises that the capability already exists.

## Current scope

The current feature is focused on:

- Browsing catalog groups and their items.
- Viewing item details and image galleries.
- Managing user-specific favorites.
- Local persistence with Drift and remote communication through Dio.
- Feature-level state management through Cubit.
- Integration into a host application that owns authentication and navigation.

## Deferred / future improvements

### Synchronization lifecycle

- Define and implement a complete synchronization trigger and retry policy if required.
- Decide whether synchronization should run only while the app is active or use a platform background mechanism.
- Define conflict handling for changes made locally and remotely.
- Add tests for retry, duplicate operations, and deletion tombstones.

The existing `isSynced` and `isDeleted` favorite metadata supports synchronization bookkeeping; it is not by itself a background synchronization service.

### Data loading and pagination

- Revisit paging if catalog size, backend pagination, or memory use requires it.
- Consider incremental loading for large group/item collections where it improves measured performance.
- Avoid introducing a generic pagination framework until the request/response and UI requirements are clear.

### Lightweight list and detailed item models

Consider separating the current item representation into:

- A lightweight model for group lists and cards.
- A full details representation fetched when the user opens an item.

This should be driven by payload size, performance measurements, or different backend response contracts rather than introduced preemptively.

### Testing

- Resolve the pending-timer issue observed in the example widget test.
- Expand widget tests around the public pages and shared state views.
- Add repository tests for offline/remote coordination and favorite synchronization metadata.
- Add host-level integration tests once the API contract and test environment are stable.

### Presentation and demonstration

- Refine the visual design and responsive behavior after the integration baseline is stable.
- Add Figma or an architectural walkthrough/video only if it materially improves how reviewers understand the feature.
- Keep the example app deliberately small and focused on demonstrating integration.

### Backend and release readiness

- Stabilize and document the FastAPI mock API contract.
- Decide on versioning and release distribution only if external consumption is required.
- Add CI checks for formatting, analysis, tests, and example validation when the repository workflow is ready.

## Known boundaries

- No authentication implementation is included.
- No admin dashboard or content-authoring UI is included.
- No production backend or hosting setup is delivered by this feature.
- A complete background synchronization service is not claimed by the current design description.
- A generic pagination framework is intentionally deferred.
- The example widget test has had a pending-timer failure that must be resolved before claiming the example test suite is clean.

## Roadmap maintenance

When a future item is implemented:

1. Add or update tests that prove the behavior.
2. Update the relevant architecture/data/state/flow document.
3. Move the item out of the future-work section.
4. Update the README only if the capability changes the feature's public scope or integration contract.
