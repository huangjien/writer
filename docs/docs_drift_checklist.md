# Docs Drift Checklist

Use this checklist when updating build scripts, CI, routing, dependencies, or release flows.

## Command Accuracy
- Verify every `make <target>` shown in `README.md` exists in `Makefile`.
- Prefer targets from `make help`; remove stale aliases from docs.
- If target behavior changes, update command descriptions and examples.

## CI Consistency
- Confirm workflow filenames in docs match `.github/workflows/*`.
- Keep CI behavior descriptions aligned with actual workflow steps.
- If release publishing changes, update both README CI section and workflow notes.

## Dependency and Version Consistency
- Keep dependency notes in docs aligned with `pubspec.yaml`.
- If platform-specific patching changes, update docs and related script references.
- Remove version pin claims from docs unless explicitly maintained.

## Runtime Configuration
- Keep `AI_SERVICE_URL` behavior accurate across:
  - app fallback defaults in Dart code
  - Makefile defaults used by `make` targets
  - README override instructions (`--dart-define`)
- Ensure env/config examples match current variable names.

## Rule Source of Truth
- Keep AI policy content only in `RULES.md`.
- Keep `AGENTS.md` as a delegating pointer to `RULES.md`.
- Do not duplicate policy bodies across both files.

## Cleanup for Removed Files
- After deleting scripts/docs/tests, remove stale references from:
  - `README.md`
  - `Makefile` comments/help text
  - CI workflow notes
  - nearby docs in `docs/`

## Verification Before Merge
- Run `make lint`.
- Run `make test`.
- Re-check `git status` for unintended docs/config drift.
