# Questionnaire

Ask all questions in one go. Show the default for each; the developer may answer "defaults" to accept all. Record the answers in the report and in AGENTS.md ("Hard rules" section).

| # | Question | Default |
|---|----------|---------|
| 1 | May agentic files (AGENTS.md, skills, subagents, specs, tool configs) be committed now, or must they stay local until the client approves? | Local. Exclude via `.git/info/exclude`; tool settings in user/local scope. |
| 2 | Documentation language for specs, docs, reports, code comments? | English |
| 3 | Chat language with the developer? | The language the developer writes in |
| 4 | Which coding agents will the team use? (Claude Code, Codex CLI, Gemini CLI, Cursor, Copilot, OpenCode, other) | Claude Code + AGENTS.md for everything else |
| 5 | Task tracker and ticket key format? (Jira `ABC-123`, Linear, GitHub Issues, none) | Jira `KEY-123`; input pasted as text if no connector |
| 6 | Spec-driven framework? (OpenSpec, GitHub Spec Kit, none) | OpenSpec |
| 7 | TDD? | Yes, strict: no production code without a failing test first. Legacy code: cover only what you touch. |
| 8 | Main and release branches; branch naming; which branch new work starts from? | Detect from git; `feature/KEY-123-title`, `bugfix/KEY-123-title` |
| 9 | Approval stops during feature work? | One: after the spec |
| 10 | Device/emulator available for verification? (Android AVD, iOS simulator, browser) | Detect; ask only if none found |
| 11 | Anything the client already raised? (secrets, licensing, data residency, AI usage policy) | None |
| 12 | Which tools may the agent install, and where? (global npm/pip, MCP servers) | User scope; nothing written into the repo if answer 1 is "local" |

## Consequences to apply

- Answer 1 = local: every generated file goes into `.git/info/exclude`; never `git add` them; settings use user/local scope; worktrees get a copy of the local files (also excluded).
- Answer 1 = commit: put skills in `.agents/skills/` and the tool-specific folders listed in `templates/tool-pointers.md`; commit on a dedicated branch `chore/agentic-setup` and let the developer open the PR.
- Answer 4 decides which pointer files and subagent formats to generate. Do not generate files for tools nobody uses.
