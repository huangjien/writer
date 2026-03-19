# UI Phase Execution Plan

## Objective
Drive a focused UI phase that improves consistency, accessibility, localization quality, and journey clarity across the core product surfaces.

## Scope
- Library
- Reader
- Editor
- Settings
- Shared navigation and shortcuts

## Principles
- Preserve feature-first architecture and existing provider boundaries
- Prefer design tokens and theme-driven styling over hard-coded values
- Keep keyboard, desktop, and mobile behaviors predictable and documented
- Ensure localization coverage for all user-visible text
- Ship small vertical UI slices with test updates

## Phase Backlog

### Slice 1: Sidebar and Navigation Consistency
- Re-enable and standardize drawer behavior in Library to match UX guidelines
- Align Reader desktop sidebar behavior with collapsible always-visible guidance
- Replace placeholder mobile tabs with meaningful destinations or remove temporary tabs

### Slice 2: Keyboard Shortcut Alignment
- Reconcile implemented sidebar shortcuts with documented shortcut contracts
- Ensure Settings shortcut wrappers are consistently applied where expected
- Add or update shortcut discoverability in existing dialogs/help surfaces

### Slice 3: Localization and Copy Integrity
- Remove hard-coded editor and settings strings from primary paths
- Route all user-visible copy through localization resources
- Add focused tests for localized critical actions and snackbars

### Slice 4: Visual System Consistency
- Replace high-impact hard-coded color and text style values with theme tokens
- Harmonize spacing and typography in list, card, and section headers
- Confirm reduced-motion and high-contrast behavior remains intact

## Validation Strategy
- Run `make lint`
- Run `make test`
- Update or add targeted widget and golden tests for touched screens
- Verify shortcut and navigation flows with deterministic widget tests

## Completion Criteria
- Core surfaces follow one navigation model per platform class
- Shortcut behavior and documentation match
- No hard-coded critical-path user-facing strings in touched UI
- All modified UI states are covered by updated tests

## Completion Status
- Slice 1 complete
- Slice 2 complete
- Slice 3 complete
- Slice 4 complete
- Targeted widget/regression suites executed for each slice
- Milestone marked complete in ROADMAP.md and STATE.md
