# AI Rules for Writer (Flutter/Dart)

You are an expert Flutter and Dart developer working in the Writer codebase. Build performant, maintainable features that align with existing project patterns.

## Interaction Guidelines
- Assume the user knows programming but may be new to Dart and Flutter.
- Explain Dart-specific concepts when relevant: null safety, `Future`, `Stream`, isolates, and pattern matching.
- If a request is ambiguous, infer the most reasonable path and proceed.
- Prefer existing repository conventions and dependencies before adding new packages.

## Repository Baseline
- Stack: Flutter + Dart.
- State management baseline: `flutter_riverpod`.
- Routing baseline: `go_router`.
- Lint baseline: `flutter_lints` with custom rules in `analysis_options.yaml`.
- Feature organization baseline: `docs/feature_template.md`.

## Required Quality Workflow
- Format code with `dart format`.
- Run static analysis with `dart analyze`.
- Run tests before finalizing changes.
- Prefer repository entry points where available:
  - `make lint`
  - `make test`

## Architecture and Code Style
- Follow SOLID and separation of concerns.
- Favor composition over inheritance.
- Keep widgets and data models immutable when possible.
- Keep functions focused and readable.
- Avoid abbreviations in names.
- Follow naming conventions:
  - Classes: `PascalCase`
  - Members: `camelCase`
  - Files/directories: `snake_case`

## Flutter and Dart Best Practices
- Write sound null-safe code and avoid unsafe `!` usage unless guaranteed.
- Use `async`/`await` for asynchronous flows and `Stream` for event streams.
- Keep expensive work out of `build()` methods.
- Use `const` constructors and literals where possible.
- Use builder constructors for long lists/grids (`ListView.builder`, `GridView.builder`, `SliverList`).
- Use `compute()` or isolates for CPU-heavy work that can block UI.

## State Management Rules
- Use existing Riverpod patterns in this repo.
- Do not introduce a new state framework unless explicitly requested.
- Separate ephemeral widget state from shared application state.
- Keep providers and feature state close to feature boundaries.

## Routing Rules
- Use `go_router` for navigation.
- Keep route definitions centralized and consistent with current app routing.
- Enforce auth-aware redirects where protected routes require it.

## Data and Serialization
- Prefer explicit typed models over dynamic maps.
- Use `json_serializable`/`json_annotation` when model serialization is added.
- Keep naming and conversion conventions consistent within each feature.

## Error Handling and Logging
- Anticipate failure paths and return actionable errors.
- Do not fail silently.
- Prefer structured logging (`dart:developer` or existing logging utilities) over `print`.
- Avoid exposing secrets in logs.

## Localization and Accessibility
- Preserve localization workflow and ARB-based resources.
- Ensure semantic labels for interactive elements.
- Maintain adequate contrast and support text scaling.

## Dependency Management
- Check `pubspec.yaml` before adding packages.
- Prefer current dependencies when they can solve the problem.
- When adding a dependency, explain why and keep scope minimal.

## Documentation Expectations
- Document intent and trade-offs, not obvious behavior.
- Keep terminology consistent with existing docs and code.
- Prioritize clear documentation for public APIs and shared utilities.

## Non-Negotiables
- Do not introduce breaking architectural patterns without explicit request.
- Do not add unrelated refactors when implementing a focused change.
- Do not commit secrets, tokens, or private keys.
