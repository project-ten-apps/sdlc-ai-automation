---
name: new-feature
description: Use when starting work on a new feature from a {{TRACKER}} task in {{PROJECT_NAME}} - worktree, {{SDD_FRAMEWORK}} spec, one approval stop, strict TDD implementation, review, verification, report.
---

# New feature: spec-driven + TDD

Chat with the developer in {{CHAT_LANGUAGE}}. All documentation (specs, design, tasks, docs, reports, code comments) in {{DOC_LANGUAGE}}.
Input: task key (`{{TICKET_EXAMPLE}}`), title, description or attachments from the tracker.
Use Context7 (MCP, or official docs) for any library or platform API you touch.

## Hard rules

- {{COMMIT_RULE}}
- Exactly one approval stop: after the spec. After that, work autonomously until the report.
- No production code without a failing test first. If you wrote code before its test, delete it and start from the test.
- Add tests only for code you touch; do not mass-cover legacy code.

## 1. Start

1. Base branch: if the feature continues an existing stream, use that branch; otherwise `{{BASE_BRANCH}}`. If unclear, pick a sensible default and say which.
2. Worktree: `git worktree add ../{{REPO_DIR}}-<KEY> -b feature/<KEY>-<kebab-title> <base>`.
3. If agentic files are local-only, copy them (AGENTS.md, CLAUDE.md, skills/agents folders, `openspec/`) into the worktree and add them to its `.git/info/exclude`. List what you copied.

## 2. Spec

1. If {{SDD_FRAMEWORK}} is not initialized: {{SDD_INIT_CMD}}.
2. Create the change (`openspec/changes/<key>-<title>/` for OpenSpec): `proposal.md` (why, what changes), spec deltas with requirements and WHEN/THEN scenarios, `design.md` (architecture, affected code, risks), `tasks.md` (small tasks, each with its test).
3. Validate ({{SDD_VALIDATE_CMD}}).
4. **STOP.** Send a short summary with file links; wait for OK or edits.

## 3. TDD implementation

For each task in `tasks.md` (use the `developer` subagent if your agent supports subagents):

1. Red: write the test ({{UNIT_TEST_DIR}} for unit, {{INTEGRATION_TEST_DIR}} for UI/integration). Run it; confirm it fails for the expected reason.
2. Green: minimal code to pass. Run the test and the related suite.
3. Refactor: clean up; tests stay green.
4. Check the task off in `tasks.md`.

If the spec turns out wrong, update it and call it out in the report; never silently diverge.

## 4. Review and verification

1. Run `code-review` and `security-audit` (diff mode) on the diff, in parallel if you can. Fix every blocker/critical finding and re-run.
2. Run `verify`. Fix failures and re-run.

## 5. Finish

1. Archive the change ({{SDD_ARCHIVE_CMD}}) so requirements merge into the main specs.
2. Report: what was done, spec links, verification result with evidence, review findings, deviations from the spec, what remains, and the commit status.
