# AI Chat Enhancement Milestone Plan

## Date
2026-03-28

## Overview
Enhance the existing AI chat infrastructure with streaming responses, improved markdown rendering, voice input, writing tools, and comprehensive test coverage.

## Motivation
The existing AI chat system provides solid functionality but lacks modern chat UX features like streaming responses, rich content rendering, and voice input. This milestone enhances the user experience while maintaining the custom backend architecture.

## Open Questions - RESOLVED

| Question | Answer |
|----------|--------|
| Backend streaming support? | **NOT AVAILABLE** - Backend requires changes to enable SSE/WebSocket streaming |
| Writing prompts customization? | **Hybrid** - Default prompts provided, users can add custom prompts |
| Voice input priority? | **Low priority** - Can be implemented later |
| Test coverage target? | **85%+** - Comprehensive coverage for AI chat components |

## Backend Analysis Summary

**Streaming NOT currently available in backend.** All AI endpoints return complete JSON responses synchronously.

Relevant backend files requiring changes:
- `src/authorconsole_api/intelligence/routes/agents.py` - Need streaming variants
- `src/authorconsole_api/intelligence/llm/providers.py` - Currently hardcodes `stream: False`
- `src/authorconsole_api/intelligence/services/qa_service.py` - Non-streaming LangChain

**Frontend can proceed with slices that don't require backend streaming.**

---

## Milestone Slices (Revised Order)

### Slice 1: Enhanced Markdown Rendering (Medium Priority) ✅ **START HERE**
**Goal:** Rich markdown display with tables, code blocks, and syntax highlighting

**Deliverables:**
- Table rendering in chat messages
- Code blocks with syntax highlighting (using flutter_highlight or similar)
- Better list formatting
- Link handling and preview

**Files to modify:**
- `lib/features/ai_chat/widgets/ai_chat_sidebar.dart` (_ChatMessageBubble)

**Tests:**
- Widget tests for markdown rendering

---

### Slice 2: Writing Assistant Tools (Medium Priority)
**Goal:** Built-in writing prompts, templates, and generation helpers (hybrid approach)

**Deliverables:**
- Writing prompt library (scene starters, character prompts, plot hooks)
- Template quick-insert UI
- Context-aware prompt suggestions
- Custom prompt management (user can add own prompts)

**Files to add:**
- `lib/features/ai_chat/services/writing_prompts_service.dart`
- `lib/features/ai_chat/widgets/writing_prompts_panel.dart`

**Tests:**
- Prompt service tests
- Prompt panel widget tests

---

### Slice 3: Mobile UX & Accessibility (Medium Priority)
**Goal:** Polish for mobile devices and accessibility

**Deliverables:**
- Improved mobile responsive layout
- Keyboard shortcuts for desktop
- Screen reader support improvements
- Touch gesture improvements

**Files to modify:**
- `lib/features/ai_chat/widgets/ai_chat_sidebar.dart`
- `lib/features/ai_chat/widgets/ai_context_toggle.dart`

**Tests:**
- Accessibility tests (Semantics)
- Responsive layout tests

---

### Slice 4: Testing & Reliability (High Priority)
**Goal:** Comprehensive test coverage for AI chat (85%+ target)

**Deliverables:**
- Unit tests for services (ai_chat_service.dart)
- Unit tests for providers (ai_chat_providers.dart)
- Widget tests for all AI chat widgets
- Integration tests for end-to-end chat flow

**Files to add:**
- `test/features/ai_chat/`

**Tests:**
- All AI chat tests passing with 85%+ coverage

---

### Slice 5: Voice Input Support (Low Priority)
**Goal:** Speech-to-text input for AI chat

**Deliverables:**
- Microphone permission handling
- Voice recording UI
- Speech-to-text integration (using flutter_tts or speech_to_text)
- Voice input state management

**Files to modify:**
- `lib/features/ai_chat/widgets/ai_chat_sidebar.dart`
- `lib/features/ai_chat/state/ai_chat_providers.dart` (new voice state)

**Tests:**
- Permission handling tests
- Voice input state tests

---

### Slice 6: Streaming Responses (Backend Required) ⏳ **WAITING ON BACKEND**
**Goal:** Real-time AI response streaming instead of loading spinner

**Status:** DEPENDS ON BACKEND IMPLEMENTATION

**Deliverables (Frontend):**
- Frontend streaming UI state management
- SSE/WebSocket client integration
- Progress indicator for partial responses
- Error handling for stream interruptions
- Graceful fallback to polling if streaming unavailable

**Files to modify:**
- `lib/features/ai_chat/services/ai_chat_service.dart`
- `lib/features/ai_chat/state/ai_chat_providers.dart`
- `lib/features/ai_chat/widgets/ai_chat_sidebar.dart`

**Backend Requirements:**
- SSE endpoint at `/agents/{agent_id}/stream`
- Modify LLM providers to support streaming
- Async generators for partial responses

**Tests:**
- Unit tests for streaming state management
- Integration tests for stream interruption handling

---

## Slice Execution Order

| Slice | Priority | Dependencies | Estimated Scope | Status |
|-------|----------|--------------|-----------------|--------|
| 1 | Medium | None | Small | Ready |
| 2 | Medium | None | Medium | Ready |
| 3 | Medium | Slice 1 | Small | Ready |
| 4 | High | None | Medium | Ready |
| 5 | Low | None | Medium | Ready |
| 6 | High | Backend streaming | Medium | Blocked |

---

## Technical Considerations

### Backend Streaming Path (For Slice 6)
When backend implements streaming, the implementation path is:

1. **Backend changes needed:**
   - Add streaming parameter to LLM providers (currently `stream: False`)
   - Create SSE endpoint in `routes/agents.py`
   - Modify services to return async generators

2. **Flutter integration:**
   - Use `dio` with `responseType: ResponseType.stream`
   - Parse SSE data events
   - Update UI in real-time

### Package Dependencies
Potential additions:
- `flutter_highlight` or `highlight` for syntax highlighting
- `speech_to_text` for voice input (low priority)
- `dio` for streaming HTTP (if not already included)

### Performance
- Lazy loading for chat history
- Pagination for large message lists
- Debounced streaming updates (Slice 6)

---

## Quality Gates
- `make lint` passes with no new warnings
- `make test` passes with **85%+ coverage** on AI chat files
- All new widgets have corresponding widget tests
- Manual testing on iOS, Android, and web

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Backend streaming delayed | Proceed with Slices 1-5, implement fallback UI |
| Voice input permissions complexity | Use existing flutter_tts setup as reference |
| New packages conflict with overrides | Test incrementally, check pub get |
| Test coverage takes too long | Prioritize high-impact tests first |

---

## Success Criteria
- ✅ Markdown rendering enhanced with tables, code blocks, highlighting
- ✅ Writing assistant tools available (prompts + templates)
- ✅ Mobile UX polished with accessibility improvements
- ✅ 85%+ test coverage on AI chat components
- ⏳ Streaming UI ready (waiting on backend)
- ⏳ Voice input available (low priority)
