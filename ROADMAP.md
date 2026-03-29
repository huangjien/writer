# Roadmap

## UI Phase

- Unify visual behavior across library, reader, editor, and settings surfaces
- Prioritize accessibility, localization safety, and responsive layout consistency
- Reduce UX friction on core user journeys before expanding feature breadth
- Keep UI changes aligned with existing provider and routing boundaries
- Execute phased plan in docs/plans/2026-03-19-ui-phase-execution-plan.md
- Status: complete

## Milestones

- UI Phase milestone: ✅ complete (Slices 1-4 delivered)
- Flow Resilience & Accessibility milestone: ✅ complete (Slices 1-3 delivered)
- Performance & Observability milestone: ✅ complete (Slices 1-3 delivered)
- AI Chat Enhancement milestone: ✅ complete (Slices 1-6 delivered)
- Milestone 5 (Next-Generation Writing Experience): 🔄 charter phase

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
- Status: ✅ complete

## Milestone 5: Next-Generation Writing Experience

- Deliver comprehensive writing experience across five major themes
- Execute charter: docs/plans/2026-03-29-milestone-5-charter.md

**Five Major Themes:**
1. **Advanced AI-Assisted Writing Workflows** - Scene suggestions, character consistency, plot tracking
2. **Writing Analytics and Progress Tracking** - Goals, streaks, dashboards, statistics
3. **Collaboration Features** - Comments, suggestions, sharing, review workflow
4. **Performance Optimization** - Build size reduction, startup time, editor performance
5. **Enhanced Offline Experience** - Robust offline editing, conflict resolution, sync resilience

## Now

- Charter review and stakeholder approval for Milestone 5
- Technical feasibility assessment for collaboration features
- Performance baseline establishment for optimization targets
- Break down themes into actionable implementation slices

## Next

- Execute Milestone 5 following phased approach:
  - Phase 1: Performance foundation (2 weeks)
  - Phase 2: Core writing features - AI + Analytics (4 weeks)
  - Phase 3: Collaboration + Offline enhancements (3 weeks)
  - Phase 4: Testing & hardening (2 weeks)
  - Phase 5: Launch preparation (1 week)

## Later

- Deepen AI-assisted writing workflows based on user feedback
- Explore advanced collaboration features (real-time editing)
- Expand analytics and insights capabilities

## Ongoing Engineering Standards

- Preserve feature-first modularity
- Avoid duplicate logic across services and repositories
- Keep functions focused and side effects explicit
- Prefer testable abstractions at layer boundaries
