# Flutter Catalog Feature tests

This folder contains automated tests for the reusable Catalog feature and its core support code.

## Run

From the package root:

```bash
flutter pub get
flutter test
```

The tests use `flutter_test` from the Flutter SDK. No mocking package is required; repository and data-source doubles are provided in `test/support/`.

## Coverage map

| Area | Covered behavior |
|---|---|
| Core domain and results | Base entity validation/equality, pagination value objects, `Result` variants |
| Core errors | Exception-to-failure mapping and Dio status/transport error mapping |
| Core extensions | Safe JSON scalar, list, map, and date accessors |
| Core networking | Dio client options and connectivity state mapping |
| Core presentation | Generic list/grid rendering, callbacks, and state-view loading/error/empty/content states |
| Catalog entities and models | Validation, immutable collections, JSON conversion, defaults |
| Catalog domain models and typedefs | Group/catalog composition and favorite-state values |
| Use cases | Repository delegation, composition, empty results, favorite status, and failure propagation |
| Drift/local data sources and mappers | CRUD reads, ordering, foreign-key dependent records, snapshot synchronization, tombstones, and direct model-to-row mapper round trips |
| Remote data sources | Endpoint paths, query/body values, response parsing, invalid payloads, and Dio exception translation |
| Repositories | Local/remote behavior, parent-group checks, catalog detail fallback, favorite synchronization, and failure mapping |
| Cubits and states | Initial loads, lazy group loads, refresh guards, favorite mutations, item detail loads, immutability |
| Presentation widgets/pages | Group/item cards and collections, list/grid layouts, retry/content states, favorites, details, navigation callbacks |
| Feature wiring | GetIt registration, `CatalogFeature`, and `CatalogScope` provider composition |

## Test support

- `fixtures.dart`: deterministic test entities and data models.
- `fake_repositories.dart`: in-memory domain repository doubles.
- `fake_data_sources.dart`: in-memory data-source doubles for repository tests.
- `test_database.dart`: in-memory Drift database factory used by local data-source tests.
- `fake_http_adapter.dart`: deterministic Dio adapter used by remote data-source tests.
- `cubit_factories.dart`: Cubit factories built from fake repositories for widget tests.

## Environment notes

- Drift local-data-source tests use an in-memory native SQLite database. They are intended to run with `flutter test` on a desktop development/CI host, not in a browser test environment.
- Tests for `app_database.g.dart` are exercised through the generated database API and the local data-source integration tests; generated code is not tested line-by-line.
- `main.dart` and `app.dart` are bootstrap files for the demo application rather than feature behavior. The app-level launch and platform-specific Drift web assets should be verified with the `example` application separately.
- The package source archive used to prepare these tests did not include `pubspec.yaml`, so dependency-resolution and analyzer/test execution could not be performed while creating this folder. Run `flutter analyze` and `flutter test` in the complete package before publishing.
