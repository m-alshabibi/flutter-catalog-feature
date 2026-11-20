# Documentation

This directory explains the architecture, behavior, integration contract, and current development boundaries of Flutter Catalog Feature.

## Reading order

1. [Architecture](architecture.md) — module boundaries, layers, domain entities, and dependency direction.
2. [Data layer](data-layer.md) — local and remote data access, persistence, error handling, and offline behavior.
3. [State management](state-management.md) — Cubits, state models, loading behavior, and provider scope.
4. [Application flows](application-flows.md) — the user-facing flows and the responsibilities involved in each one.
5. [Integration guide](integration-guide.md) — how a host application configures and embeds the feature.
6. [Testing](testing.md) — test strategy, commands, and known validation concerns.
7. [Architecture decisions](architecture-decisions.md) — the reasoning behind important design choices.
8. [Roadmap](roadmap.md) — deferred improvements and known limitations.

## Documentation conventions

The documents distinguish three kinds of information:

- **Current design / implementation:** behavior and structure agreed as part of the current feature.
- **Deferred:** intentionally left out of the first version.
- **Future consideration:** a possible improvement, not a current capability.

Do not treat a future consideration as an implemented feature. When code changes, update the relevant design document and this index if files are added or removed.
