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
- Performance & Observability milestone: complete (Slices 1-3 delivered)
- AI Chat Enhancement milestone: in progress (Slices 1-6 planned)

## Flow Resilience & Accessibility Phase
- Reduce friction across library-to-reader-to-editor transitions
- Improve offline and sync conflict clarity in core journeys
- Expand accessibility and localization consistency checks
- Execute plan in docs/plans/2026-03-19-flow-resilience-accessibility-milestone-plan.md

## Performance & Observability Phase
- Harden diagnostics for large libraries and long chapters
- Improve flow efficiency in library and reader pathways
- Strengthen admin observability for support operations
- Execute plan in docs/plans/2026-03-20-performance-observability-milestone-plan.md
- Status: complete

## AI Chat Enhancement Phase
- Enhance existing AI chat with streaming, rich rendering, voice input, writing tools
- Execute plan in docs/plans/2026-03-28-ai-chat-enhancement-milestone-plan.md

## Now
- Execute AI Chat Enhancement milestone
- Maintain high confidence through lint and test gates
- Keep routing, provider state, and repository boundaries coherent

## Next
- Complete remaining slices in AI Chat Enhancement milestone
- Define follow-on milestone after AI chat handoff
- Prioritize highest-impact reliability and maintainability debt

## Later
- Deepen AI-assisted writing workflows without coupling to UI internals
- Explore advanced writing workflow optimizations after reliability baseline

## Ongoing Engineering Standards
- Preserve feature-first modularity
- Avoid duplicate logic across services and repositories
- Keep functions focused and side effects explicit
- Prefer testable abstractions at layer boundaries
