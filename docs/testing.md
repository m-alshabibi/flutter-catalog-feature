# Testing

## 1. Testing goals

Tests should verify domain rules, repository behavior, controller state transitions, and the integration surface exposed to a host application. The test strategy should focus on observable behavior and avoid coupling tests to private implementation details.

## 2. Test layers

### Domain tests

Cover entity invariants and use-case behavior, including:

- Empty IDs are rejected by the base entity invariant.
- Entity equality uses runtime type and identifier.
- `GetFavoriteCatalogItemsUseCase` returns an empty list when the user has no favorite records.
- Favorite relationships are resolved to catalog items through the catalog repository.
- `GetCatalogItemsWithFavoriteStatusUseCase` groups results by `groupId` and provides the user's favorite status.

### Data tests

Cover repository and data-source behavior, including:

- Mapping between database/API models and domain entities.
- Local reads and writes.
- Remote success and failure handling.
- Offline behavior and preservation of local favorite changes.
- Favorite synchronization metadata (`isSynced`, `isDeleted`).
- Drift migrations when schema changes are introduced.

Use controlled fakes or mocks for remote services and connectivity where a live network is not the subject of the test.

### Cubit tests

The project has developed tests for the main controllers:

- `CatalogCubit`
- `FavoritesCubit`
- `CatalogItemDetailsCubit`

Controller tests should check meaningful state sequences: initial loading, successful data, empty data, refresh while content exists, failures, and item-level favorite updates. Assert both the emitted state and any relevant use-case invocation.

### Widget tests

Widget tests should focus on the feature's public presentation behavior:

- Correct loading/empty/error/content view selection.
- Rendering group and item content.
- Switching list/grid presentation where supported.
- Favorite button state and update indication.
- Host callbacks being invoked when a user selects a group or item.

Widget tests should inject controlled dependencies. Avoid opening live network connections or starting unmanaged background work in a widget test.

### Integration / smoke tests

A host-level smoke test should verify that the feature can be initialized, mounted above `MaterialApp`, and navigated through the principal pages. Full integration tests against a deployed backend are deferred until the API contract and environment are stable.

## 3. Commands

Run these commands from the package root:

```bash
flutter pub get
flutter analyze
flutter test
```

Run the example's checks from its directory:

```bash
cd example
flutter pub get
flutter analyze
flutter test
```

If Drift code generation is required after changing database declarations, run the generator configured by the project, for example:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Run code generation only when generated source needs to be refreshed; it is not a substitute for tests.

## 4. Test isolation and lifecycle

- Reset or configure GetIt between tests so registrations do not leak between cases.
- Close Cubits and streams created directly by a test.
- Await asynchronous operations started by the test.
- Ensure timers, stream subscriptions, database connections, and other owned resources are cancelled or closed.
- Use fake repositories/use cases when testing presentation behavior that does not require a real database.
- For Drift tests, use a test-appropriate database implementation and close it in teardown.

A pending timer at the end of a widget test is a lifecycle failure, not a reason to increase arbitrary pump delays. Trace which dependency or controller created it, then give that object an explicit cancellation/disposal path or replace it with a deterministic fake for the test.

## 5. Current validation note

During the recent example-app widget-test work, the test runner reported:

```text
A Timer is still pending even after the widget tree was disposed.
```

This issue was not established as resolved in the project discussion. Treat the example widget test as an outstanding validation item until the timer's owner is identified and the test passes reliably. Do not document the example test suite as passing before rerunning it.

## 6. Pre-release verification

Before creating a GitHub release or presenting the repository as ready:

- [ ] `flutter analyze` succeeds at the package root.
- [ ] `flutter test` succeeds at the package root.
- [ ] Example dependency resolution succeeds.
- [ ] Example analysis succeeds.
- [ ] Example widget tests succeed without pending timers.
- [ ] The demo app runs on at least one intended target platform.
- [ ] Web Drift assets are present and correctly referenced if Web is supported.
- [ ] Generated Drift source is current.
- [ ] No credentials, local database files, build outputs, or environment secrets are committed.
