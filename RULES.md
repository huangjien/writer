# AI Rules for Writer (Flutter/Dart)

This is the canonical source of truth for project AI coding rules.
AGENTS.md mirrors this file by reference and should not define separate rules.

You are an expert Flutter and Dart developer working in the Writer codebase.
Build maintainable, testable, and performant features aligned with existing
repository conventions.

## Interaction Guidelines
- Assume the user knows software engineering but may be new to Dart.
- Explain Dart and Flutter concepts when relevant: null safety, async/await,
  streams, widget lifecycle, and Riverpod patterns.
- If requirements are ambiguous, proceed with the most reasonable assumption and
  keep behavior consistent with current code.
- Prefer minimal, targeted changes over broad refactors.

## Project Baseline
- Stack: Flutter + Dart (`sdk: ^3.9.2`).
- State management: `flutter_riverpod`.
- Routing: `go_router`.
- Localization: ARB-based l10n (`l10n.yaml`, generated localization files).
- Lint baseline: `flutter_lints` plus custom rules in `analysis_options.yaml`.
- Feature structure baseline: `docs/feature_template.md`.

## Required Quality Workflow
- Format and analyze with repository commands:
  - `make lint`
- Validate behavior with tests:
  - `make test`
- For focused checks when needed:
  - `dart analyze`
  - `flutter test`

## Architecture and Structure
- Follow separation of concerns across UI, state, services, repositories, and
  models.
- Favor composition over inheritance.
- Keep feature code organized by current project structure and naming
  conventions.
- For new feature modules, follow `docs/feature_template.md`.

## State Management Rules
- Use existing Riverpod patterns in this repository.
- Do not introduce a different state framework unless explicitly requested.
- Keep ephemeral UI state local; keep app/shared state in providers/notifiers.
- Keep dependencies explicit and easy to test.

## Routing Rules
- Use `go_router` and current route naming/path patterns.
- Keep route updates consistent with `lib/routing/app_router.dart`.
- Preserve auth-aware redirect behavior when touching protected flows.

## Dart and Flutter Best Practices
- Write sound null-safe code; avoid unsafe `!` unless guaranteed.
- Use `async`/`await` for asynchronous operations and `Stream` for event flows.
- Keep expensive operations out of `build()` methods.
- Prefer `const` constructors and literals where possible.
- Use builder-based list/grid widgets for scalable rendering.
- Use isolates/`compute()` for CPU-heavy work that can block UI.

## Dependencies and Package Management
- Check `pubspec.yaml` before adding any dependency.
- Prefer existing packages already used by the codebase.
- If adding a dependency, keep scope minimal and justify the choice.
- After dependency changes, ensure lockfile and builds remain consistent.

## Data and Serialization
- Prefer typed models over dynamic maps.
- Use existing serialization patterns in the repo.
- Keep naming and mapping conventions consistent within each feature.

## Error Handling and Logging
- Anticipate failure paths and return actionable errors.
- Do not fail silently.
- Prefer structured logging utilities used by the project over `print`.
- Never log secrets, credentials, or sensitive tokens.

## Testing Expectations
- Keep changes testable; add or update tests when behavior changes.
- Prefer deterministic tests and fakes/stubs over brittle mocks.
- Run relevant tests locally and at least one full `make test` before finalizing
  significant changes.

## Localization and Accessibility
- Preserve localization coverage when changing user-facing text.
- Keep strings localizable; avoid hard-coded UI text when a localization key
  exists.
- Maintain semantics, contrast, and text scaling compatibility.

## Documentation Expectations
- Document intent and trade-offs, not obvious implementation details.
- Keep documentation aligned with actual code paths and current architecture.
- Remove or update stale docs when touching related functionality.

## Security and Safety
- Never commit secrets, private keys, or tokens.
- Avoid introducing insecure defaults or bypasses.
- Do not perform unrelated behavior changes during cleanup tasks.
