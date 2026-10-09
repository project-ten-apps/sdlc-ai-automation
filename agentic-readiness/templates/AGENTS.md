# AGENTS.md - {{PROJECT_NAME}}

Instructions for AI coding agents working in this repository. Tool-specific files (CLAUDE.md, GEMINI.md, Copilot/Cursor rules) only point here; keep this file the single source of truth and under ~200 lines. Link to deeper docs instead of pasting them.

## Hard rules

- {{COMMIT_RULE}}  <!-- e.g. "Do not commit or push agentic files until the client approves; they are listed in .git/info/exclude." -->
- Documentation, specs, reports and code comments: {{DOC_LANGUAGE}}. Chat with the developer: {{CHAT_LANGUAGE}}.
- Spec-driven: every feature starts as a {{SDD_FRAMEWORK}} change; one approval stop after the spec.
- TDD: no production code without a failing test first. Legacy code: add tests only for what you touch.
- Never print, copy or log full secret values. Never add new secrets to the repo.
- Evidence before claims: "done", "passes", "fixed" must be backed by the command you ran and its result.
- Keep diffs minimal and in scope; no drive-by refactoring.

## Project overview

{{ONE_PARAGRAPH_WHAT_THE_APP_DOES}}

- Stack: {{LANGUAGES_AND_VERSIONS}}
- Platforms: {{PLATFORMS}}
- Architecture: {{ARCHITECTURE_SUMMARY}}

## Module map

<!-- Generated from graphify-out/GRAPH_REPORT.md; refresh with the codebase-map skill. -->

| Module / folder | Responsibility |
|---|---|
| {{MODULE}} | {{RESPONSIBILITY}} |

Key flows: {{KEY_FLOWS}} (see `graphify-out/GRAPH_REPORT.md` for details).

## Commands

All verified on {{DATE}}.

| Purpose | Command |
|---|---|
| Install deps | {{CMD_INSTALL}} |
| Build | {{CMD_BUILD}} |
| Unit tests | {{CMD_UNIT_TEST}} |
| Integration / instrumented tests | {{CMD_INTEGRATION_TEST}} |
| Lint / analyze | {{CMD_LINT}} |
| Format | {{CMD_FORMAT}} |

## Conventions

- Branches: {{BRANCH_NAMING}}; base branch: {{BASE_BRANCH}}. One worktree per work stream.
- Tickets: {{TRACKER}} keys like `{{TICKET_EXAMPLE}}`.
- Code style: {{STYLE_NOTES}}
- Tests live in: {{TEST_LOCATIONS}}

## Workflow

Project skills (in `{{SKILLS_DIR}}`): `new-feature`, `bugfix`, `verify`, `code-review`, `security-audit`, `codebase-map`.

Feature flow: spec-writer -> developer approval of the spec -> developer (TDD) -> code-reviewer + security-reviewer (parallel) -> qa-verifier -> report.
If your agent has no subagents, run the same roles sequentially using the files in `{{AGENTS_DIR}}` as prompts.

## Tools

- Library and API docs: Context7 (MCP if available, otherwise `npx ctx7` or official docs). Do not rely on memory for versions or APIs.
- Code map: graphify (`graphify-out/`). Query it before broad code searches.
- {{STACK_TOOLS}}

## Security notes

{{KNOWN_SECURITY_FINDINGS_SUMMARY}}  <!-- no secret values; reference the report -->
