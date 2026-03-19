# State

## Date
2026-03-19

## Active Phase
- UI Phase
- Focus: consistency, accessibility, localization safety, and journey clarity
- Execution plan: docs/plans/2026-03-19-ui-phase-execution-plan.md

## UI Execution Focus
- Slice 1 in queue: sidebar and navigation consistency
- Slice 2 in queue: keyboard shortcut alignment
- Primary targets: library, reader, editor, settings

## Current Baseline
- Repository is an existing Flutter/Dart app with feature-first structure
- GSD foundation docs are initialized: PROJECT.md, ROADMAP.md, STATE.md
- Codebase map refreshed on 2026-03-19 to guide future scoped changes

## Codebase Map Snapshot
- Entry points: lib/main.dart -> lib/app.dart -> lib/routing/app_router.dart
- Primary layers: features, state, services, repositories, models, shared, theme, routing
- State and navigation: Riverpod provider graph with go_router route composition
- Data boundaries: remote_repository for API, local_storage_repository for local cache
- Sync path: app lifecycle monitor coordinates sync and background refresh services
- Quality gates: make lint, make analyze, make test

## Current Priorities
- Keep app architecture stable while iterating features
- Validate all changes through lint and tests
- Maintain clear boundaries across UI, state, services, and repositories

## Ready Commands
- `make lint`
- `make analyze`
- `make test`

## Risks To Watch
- Cross-layer coupling between feature widgets and data access
- Duplicate business logic in multiple providers/services
- Route growth without consistent ownership boundaries

## Next Update Trigger
Update this file whenever roadmap priorities, architecture assumptions, or quality gates change.
