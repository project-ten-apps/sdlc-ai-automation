---
name: bugfix
description: Use when fixing a bug from {{TRACKER}} in {{PROJECT_NAME}} - reproduce, find the root cause, failing test first, minimal fix, review, verification, report.
---

# Bugfix: systematic debugging + TDD

Chat in {{CHAT_LANGUAGE}}; docs, reports and code comments in {{DOC_LANGUAGE}}.
Use Context7 (MCP, or official docs) for any library or platform API involved.

## Hard rules

- {{COMMIT_RULE}}
- No fix without a failing test that reproduces the bug.
- Root cause before fix: no "try this and see" patches.
- Keep the fix minimal; no refactoring outside the bug's scope.
- After 3 failed fix attempts, STOP and report: the problem is probably architectural; discuss before continuing.

## Steps

1. **Intake.** Key, steps to reproduce, expected vs actual, device/OS/version, logs, screenshots. If steps are missing, infer from logs and code and state the assumption.
2. **Branch.** Worktree `../{{REPO_DIR}}-<KEY>` on `bugfix/<KEY>-<kebab-title>` from the branch where the bug lives; copy local agentic files and exclude them if they are local-only.
3. **Reproduce.** On the device/emulator (see `verify`) and/or from the stack trace. Record evidence.
4. **Investigate.** Read the full error; trace data flow back to the source; check recent changes (`git log -p` on the involved files); compare with a working code path; test one hypothesis at a time.
5. **Root cause.** Write it in 1-3 sentences.
6. **Red.** A test ({{UNIT_TEST_DIR}} if possible, else {{INTEGRATION_TEST_DIR}}) that fails because of the bug.
7. **Green.** Minimal fix; the new test and the existing suite pass.
8. **Prove the guard.** Temporarily revert the fix, confirm the test fails, restore the fix.
9. **Spec.** If the bug reveals a missing or wrong requirement, update the spec with a small change.
10. **Review.** `code-review` and `security-audit` (diff mode); fix blockers.
11. **Verify.** `verify`, including the original reproduction steps.
12. **Report.** Root cause, fix, the guarding test, verification evidence, regressions to watch, commit status.
