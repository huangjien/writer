# Roadmap

## UI Phase
- Unify visual behavior across library, reader, editor, and settings surfaces
- Prioritize accessibility, localization safety, and responsive layout consistency
- Reduce UX friction on core user journeys before expanding feature breadth
- Keep UI changes aligned with existing provider and routing boundaries
- Execute phased plan in docs/plans/2026-03-19-ui-phase-execution-plan.md
- Status: complete

## Milestones
- UI Phase milestone: complete (Slices 1-4 delivered)
- Flow Resilience & Accessibility milestone: complete (Slices 1-3 delivered)

## Flow Resilience & Accessibility Phase
- Reduce friction across library-to-reader-to-editor transitions
- Improve offline and sync conflict clarity in core journeys
- Expand accessibility and localization consistency checks
- Execute plan in docs/plans/2026-03-19-flow-resilience-accessibility-milestone-plan.md

## Now
- Stabilize core writing and reading flows
- Maintain high confidence through lint and test gates
- Keep routing, provider state, and repository boundaries coherent
- Complete Slice 1: journey transition clarity
- Complete Slice 2: offline and sync UX reliability
- Complete Slice 3: accessibility and localization consistency

## Next
- Harden performance diagnostics for large libraries and long chapters
- Strengthen admin observability for support operations
- Define and start the next milestone scope

## Later
- Deepen AI-assisted writing workflows without coupling to UI internals
- Explore advanced writing workflow optimizations after reliability baseline

## Ongoing Engineering Standards
- Preserve feature-first modularity
- Avoid duplicate logic across services and repositories
- Keep functions focused and side effects explicit
- Prefer testable abstractions at layer boundaries
