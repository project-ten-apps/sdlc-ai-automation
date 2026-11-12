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
- No feature changelogs or task history in this file; it describes how the project works now. History lives in git, specs and PRs.

## Needs approval

Ask the developer before: {{NEEDS_APPROVAL}}  <!-- e.g. new dependency, stack/UI framework change, DB schema or API contract change, build/CI config, deleting files, anything touching signing or secrets -->

## Project overview

{{ONE_PARAGRAPH_WHAT_THE_APP_DOES}}

- Stack: {{LANGUAGES_AND_VERSIONS}}
- Platforms: {{PLATFORMS}}
- Architecture: {{ARCHITECTURE_SUMMARY}}
- Preferred UI stack for new code: {{UI_STACK}}  <!-- e.g. "Jetpack Compose; XML views only when editing legacy screens" -->

## Module map

<!-- Generated from graphify-out/GRAPH_REPORT.md; refresh with the codebase-map skill. -->

| Module / folder | Responsibility |
|---|---|
| {{MODULE}} | {{RESPONSIBILITY}} |

Key flows: {{KEY_FLOWS}} (see `graphify-out/GRAPH_REPORT.md` for details).

Typical feature layout (copy this shape for new features; example: {{EXAMPLE_FEATURE}}):

```
{{FEATURE_FILE_PATHS}}
```

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

Known-red checks (already failing on `{{BASE_BRANCH}}`; do not try to fix them unless asked, and do not count them as your regressions):

| Check | Failure | Since / ticket |
|---|---|---|
| {{KNOWN_RED_CHECK}} | {{KNOWN_RED_FAILURE}} | {{KNOWN_RED_REF}} |

If there are none, write "None as of {{DATE}}."

## Long-running commands

Builds, emulator/simulator boot and instrumented tests can outlast the agent's command timeout. Never wait for them with a fixed `sleep`.

If your agent has its own background-command tool, use it. Otherwise use the recipe below, which records the exit code as the last log line. Logs go outside the worktree: `{{LOG_DIR}}`.

1. Start: {{BACKGROUND_RUN}}  <!-- macOS/Linux: `nohup sh -c '<cmd> > "{{LOG_DIR}}/<name>.log" 2>&1; echo "EXIT $?" >> "{{LOG_DIR}}/<name>.log"' > /dev/null 2>&1 &`; Windows: `$L = (Get-Item '{{LOG_DIR}}').FullName; Start-Process -FilePath cmd.exe -ArgumentList '/c', "<cmd> > ``"$L\<name>.log``" 2>&1 && (echo EXIT 0)>> ``"$L\<name>.log``" || (echo EXIT 1)>> ``"$L\<name>.log``"" -WindowStyle Hidden` (always quote the log path: workspace paths often contain spaces) -->
2. Poll the end of the log every 15-30 s (`tail -n 40 <log>` / `Get-Content <log> -Tail 40`) and report progress to the developer on long runs.
3. Done means an explicit marker, not elapsed time: a line matching `^EXIT [0-9]+` for every command, plus {{DONE_MARKERS}}  <!-- from the stack guide, e.g. `BUILD SUCCESSFUL` / `BUILD FAILED`, `sys.boot_completed` = 1, test summary line -->
4. Error-looking lines before the marker (warnings, test names) are not the result; wait for the failure marker or `EXIT` non-zero, then read the full error. If you abandon a run, kill it so it does not hold locks (Gradle daemon, simulator).

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
