# Tool pointers: one AGENTS.md, many agents

Generate only the rows for tools listed in questionnaire answer 4. Locations checked against vendor docs on 2026-10-09; re-check with Context7 or the vendor docs if a tool behaves differently.

## Project instructions

| Tool | Reads AGENTS.md? | What to add |
|---|---|---|
| Claude Code | Only when no CLAUDE.md exists | `CLAUDE.md` = `templates/CLAUDE.md` (first line `@AGENTS.md`) |
| Codex CLI | Yes (root down to cwd) | Nothing |
| Gemini CLI | No, by default | `.gemini/settings.json`: `{"context": {"fileName": ["AGENTS.md", "GEMINI.md"]}}` |
| Cursor | Yes | Optional `.cursor/rules/*.mdc` only for path-scoped rules |
| GitHub Copilot | Yes (also CLAUDE.md, GEMINI.md) | Optional `.github/copilot-instructions.md`: "Follow AGENTS.md." |
| Windsurf / Devin | Yes | Nothing |
| OpenCode | Yes | Nothing |

## Project skills

| Tool | Folder |
|---|---|
| Codex, Gemini, Cursor, Copilot, Windsurf/Devin, OpenCode | `.agents/skills/<name>/SKILL.md` |
| Claude Code (does not read `.agents/skills`) | `.claude/skills/<name>/SKILL.md` (copy, or a symlink/junction to `.agents/skills/<name>`) |

## Subagents

The templates in `templates/agents/` use Markdown with YAML frontmatter (`name`, `description`) and a plain-language "Tools" line. Adapt per tool:

| Tool | Folder | Format notes |
|---|---|---|
| Claude Code | `.claude/agents/<name>.md` | Frontmatter `name`, `description`, optional `tools: Read, Grep, Glob, Bash` (omit to inherit all), `model` |
| Gemini CLI | `.gemini/agents/<name>.md` | Frontmatter `name`, `description`, optional `tools` list |
| Cursor | `.cursor/agents/<name>.md` (also reads `.claude/agents`) | Frontmatter `name`, `description` |
| GitHub Copilot | `.github/agents/<name>.agent.md` (VS Code also reads `.claude/agents`) | Frontmatter `name`, `description`, optional `tools` list |
| OpenCode | `.opencode/agents/<name>.md` | Frontmatter `description`, `mode: subagent`, optional `tools`/`permission` map |
| Codex CLI | `.codex/agents/<name>.toml` | TOML: `name`, `description`, `developer_instructions = """..."""` (body of the template) |
| Windsurf / Devin | No file-based subagents documented | Put the role prompts in `docs/agent-roles.md` and reference them from AGENTS.md |

Read-only roles (code-reviewer, security-reviewer): restrict tools to read/search plus shell for read-only commands where the tool supports a tools list; otherwise state "read-only, never edit files" in the body (already in the templates).

## Local-only mode

If agentic files must stay local, add every generated path to `.git/info/exclude`, for example:

```
AGENTS.md
CLAUDE.md
GEMINI.md
.agents/
.claude/
.gemini/
.cursor/
.codex/
.opencode/
.github/agents/
.github/skills/
.github/copilot-instructions.md
openspec/
graphify-out/
```

Only list paths that are not already tracked; if a tracked file (e.g. an existing `.github/` workflow) shares a folder, list the generated files individually.
