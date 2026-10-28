# agentic-readiness

A portable, vendor-neutral skill that prepares an existing codebase for agentic AI development: questionnaire, readiness audit, AGENTS.md and code map, tooling, security audit, project skills and subagents, migration plan and a pilot task.

It uses the open [Agent Skills](https://agentskills.io) format (`SKILL.md` with `name` + `description` frontmatter), so the same folder works in Claude Code, Codex CLI, Gemini CLI, Cursor, GitHub Copilot, Windsurf/Devin and OpenCode. For the projects it sets up, `AGENTS.md` is the single source of truth and tool-specific files (CLAUDE.md, GEMINI.md, Copilot/Cursor rules) only point to it.

## Layout

```
agentic-readiness/
  SKILL.md                 short workflow (steps 0-7)
  questionnaire.md         the one up-front question round, with defaults
  scripts/                 validate-report.ps1 / .sh: checks the readiness report
  stacks/                  android.md, flutter.md, generic.md
  templates/
    AGENTS.md              primary project instruction file
    CLAUDE.md              pointer: @AGENTS.md + Claude-only notes
    tool-pointers.md       per-tool folders/formats for instructions, skills, subagents
    skills/<name>/SKILL.template.md   new-feature, bugfix, verify, code-review,
                                      security-audit, codebase-map
    agents/*.md            spec-writer, developer, code-reviewer,
                           security-reviewer, qa-verifier
    reports/agentic-readiness-report.md
install.ps1                installs the skill for the tools you use
```

Project skill templates are named `SKILL.template.md` so agents do not load them as live skills; the workflow renders them into `<skills-dir>/<name>/SKILL.md` inside the target project.

## Install (Windows, PowerShell 5.1 or 7)

```powershell
git clone https://github.com/project-ten-apps/sdlc-ai-automation.git "$HOME\agent-skills"   # or keep it where it is
cd "$HOME\agent-skills"
./install.ps1                                # junctions into ~/.claude/skills and ~/.agents/skills
```

| Option | Effect |
|---|---|
| (default) | `-Targets claude,agents -Mode Link`: covers all seven tools; `git pull` updates them all |
| `-Mode Copy` | Independent copies instead of junctions |
| `-Targets all` or a list | Also the tool-specific folders (gemini, cursor, copilot, opencode, windsurf). Not needed with `agents`, and causes duplicates |
| `-Force` | Replace an existing install |
| `-Instructions codex,gemini,...` | Append a pointer snippet (between marker comments, idempotent) to that tool's global instruction file |
| `-SnippetPath file.md` | Write the pointer snippet to a file to paste into any other tool's rules |
| `-Uninstall` | Remove from the given targets and instruction files |
| `-WhatIf` | Show what would change |

Junctions need no admin rights or Developer Mode. If execution policy blocks the script: `powershell -ExecutionPolicy Bypass -File .\install.ps1`.

## Where each tool looks (checked 2026-10-09)

| Tool | User skills | Project skills | Instructions | How to use the skill |
|---|---|---|---|---|
| Claude Code | `~/.claude/skills` | `.claude/skills` | `CLAUDE.md` (reads `AGENTS.md` only without a CLAUDE.md) | Auto-triggers from the description, or `/agentic-readiness` |
| Codex CLI | `~/.agents/skills` (`~/.codex/skills` deprecated) | `.agents/skills` | `AGENTS.md`; global `~/.codex/AGENTS.md` | Ask, or pick it from `/skills` |
| Gemini CLI | `~/.gemini/skills` or `~/.agents/skills` | `.gemini/skills` or `.agents/skills` | `GEMINI.md`; add `AGENTS.md` via `context.fileName` | Ask; Gemini activates matching skills |
| Cursor | `~/.cursor/skills`, `~/.agents/skills` (also `~/.claude/skills`) | `.cursor/skills`, `.agents/skills`, `.claude/skills` | `AGENTS.md`, `.cursor/rules/*.mdc` | Ask in Agent mode |
| GitHub Copilot | `~/.copilot/skills`, `~/.agents/skills` (VS Code also `~/.claude/skills`) | `.github/skills`, `.agents/skills`, `.claude/skills` | `.github/copilot-instructions.md`, `AGENTS.md` | Ask in agent mode / Copilot CLI |
| Windsurf / Devin | `~/.codeium/windsurf/skills`, `~/.agents/skills` | `.devin/skills` (`.windsurf/skills`), `.agents/skills` | `AGENTS.md`, `.windsurf/rules` | Ask in Cascade |
| OpenCode | `~/.config/opencode/skills`, `~/.agents/skills`, `~/.claude/skills` | `.opencode/skills`, `.agents/skills`, `.claude/skills` | `AGENTS.md` (falls back to CLAUDE.md) | Ask; the agent loads the skill tool |

Notes:
- Cursor, Copilot (VS Code) and OpenCode also read `~/.claude/skills`, so with the default install they may list the skill twice. Harmless; uninstall one target if it bothers you.
- Tools without Agent Skills support (or a tool you are unsure about): run `./install.ps1 -Targets @() -SnippetPath .\agentic-readiness.rules.md` and paste the snippet into its rules or system prompt. The snippet tells the agent to read `SKILL.md` and follow it.
- Other machines / other Claude accounts: clone this repo and run `install.ps1`. Skills saved in a claude.ai account sync only for that account; this repo is the portable copy.
- On macOS/Linux, symlink instead: `ln -s "$PWD/agentic-readiness" ~/.claude/skills/ && ln -s "$PWD/agentic-readiness" ~/.agents/skills/`.

## Using it

In the target repository, ask your agent: "Prepare this repo for agentic development". For a read-only assessment (nothing created or installed in the repo, report written outside it), ask: "Audit this repo for agentic readiness, audit only". For the full setup it asks the questionnaire once, then runs the audit, writes AGENTS.md and pointers, installs tools, runs the security audit, generates project skills and subagents, writes the migration plan, and stops to pick a pilot task.

## Updating

Edit files here and commit. With `-Mode Link`, every tool sees the change immediately (restart running sessions). With `-Mode Copy`, re-run `./install.ps1 -Mode Copy -Force`.

## License

[MIT](LICENSE) © 2026 Andrei Savinski
