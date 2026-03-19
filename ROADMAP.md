# Roadmap

## UI Phase
- Unify visual behavior across library, reader, editor, and settings surfaces
- Prioritize accessibility, localization safety, and responsive layout consistency
- Reduce UX friction on core user journeys before expanding feature breadth
- Keep UI changes aligned with existing provider and routing boundaries
- Execute phased plan in docs/plans/2026-03-19-ui-phase-execution-plan.md

## Now
- Stabilize core writing and reading flows
- Maintain high confidence through lint and test gates
- Keep routing, provider state, and repository boundaries coherent
- Start Slice 1: sidebar and navigation consistency
- Start Slice 2: keyboard shortcut alignment

## Next
- Reduce friction across library-to-reader-to-editor transitions
- Improve offline and sync conflict clarity
- Expand accessibility and localization consistency checks

## Later
- Deepen AI-assisted writing workflows without coupling to UI internals
- Improve performance diagnostics for large libraries and long chapters
- Strengthen admin observability for support operations

## Ongoing Engineering Standards
- Preserve feature-first modularity
- Avoid duplicate logic across services and repositories
- Keep functions focused and side effects explicit
- Prefer testable abstractions at layer boundaries
