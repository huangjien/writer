# Writer Project

## Mission

Writer is a cross-platform Flutter application for planning, drafting, reading, and managing long-form fiction with offline-first behavior and sync-aware workflows.

## Product Scope

- Authentication and session management
- Novel library and metadata management
- Chapter reading with progress tracking
- Chapter editing and creation
- Story planning tools (characters, scenes, templates, summaries)
- Admin and diagnostics surfaces
- AI-assisted chat and context tools

## Technical Baseline

- Stack: Flutter + Dart
- State management: Riverpod
- Navigation: go_router
- Core layers: features, state, services, repositories, models, shared, theme, routing
- Quality gates: lint, analyze, test

## Architectural Shape

- App bootstrap starts in `lib/main.dart` and mounts `lib/app.dart`
- Route graph is centralized in `lib/routing/app_router.dart`
- Domain behavior is feature-first under `lib/features/*`
- Cross-cutting orchestration is in `lib/state/*` and `lib/services/*`
- Data access and persistence boundaries are in `lib/repositories/*`

## Non-Goals

- Rewriting framework choices
- Introducing parallel architecture styles that duplicate existing patterns
- Coupling feature logic directly to low-level platform code

## Working Agreements

- Keep changes modular and feature-scoped
- Prefer provider-driven orchestration over ad hoc global state
- Validate with lint and tests before closing a change
