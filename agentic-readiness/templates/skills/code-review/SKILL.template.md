---
name: code-review
description: Use to review a {{PROJECT_NAME}} diff against its spec, the project architecture and test quality before verification; prefer this over generic code review in this project.
---

# Code review

Read-only: never edit files. Findings in {{DOC_LANGUAGE}}; summary to the developer in {{CHAT_LANGUAGE}}.
Use Context7 (MCP, or official docs) to check correct, current usage of libraries and APIs in the diff.

## Inputs

The diff of the worktree vs its base branch, the spec change, AGENTS.md and the code map (`graphify-out/`).
Judge the diff itself, not the implementer's description: an author's or subagent's "done" is not evidence.

## Checklist

1. **Spec conformance:** every requirement and scenario implemented; nothing implemented that the spec does not ask for; `tasks.md` matches reality.
2. **Tests (TDD):**
   - Each task has a test; each changed production behavior is covered by a test in the diff.
   - For a sample of new tests, name the production change that would make it fail. If you cannot, the test proves nothing (blocker).
   - Tests assert real behavior, not mock behavior; mocks only at true boundaries (network, OS services, third-party SDKs); no test-only code in production classes.
   - One behavior per test, descriptive names; no disabled or skipped tests; edge cases and error paths covered.
   - Bugfix: a regression test that reproduces the original bug.
   - TDD exceptions (resources, build config, generated code, manual-only steps) listed with a reason.
3. **Architecture:** follows the module's existing patterns ({{ARCHITECTURE_SUMMARY}}); no new pattern without a reason in `design.md`.
4. **Correctness:** null-safety, lifecycle and resource leaks, blocking the main/UI thread, error handling, concurrency, configuration/state restoration.
5. **Platform specifics:** {{PLATFORM_REVIEW_POINTS}}
   <!-- Android: strings/dimens/colors in resources, localization, accessibility. Flutter: const constructors, BuildContext across async gaps, dispose of controllers, l10n, semantics. -->
6. **Simplicity:** dead code, duplication, over-engineering, features beyond what the tests require, drive-by refactoring.
7. **Security smells:** hand anything suspicious to `security-audit`.

## Output

Findings as: severity (blocker / major / minor / nit), `file:line`, problem, suggested fix. End with a verdict: approve / changes required.
