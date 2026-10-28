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

## Secret read protection

Goal: agents never read credential files, even ignored ones. `.gitignore` does not stop an agent from reading a file. Use the same pattern list everywhere, trimmed to what exists in the repo:

```
.env  .env.*  (allow .env.example)  *.jks  *.keystore  *.p12  *.pem  *.key
key.properties  keystore.properties  local.properties  secrets.*  service-account*.json
```

| Tool | Mechanism | Example |
|---|---|---|
| Claude Code | `permissions.deny` in `.claude/settings.json` (shared) or `.claude/settings.local.json` (local) | `"deny": ["Read(./.env)", "Read(./.env.*)", "Read(**/*.jks)", "Read(**/key.properties)"]` |
| Codex CLI | Filesystem permission profile in `~/.codex/config.toml` (or project `.codex/config.toml`), access `deny` | `[permissions.<profile>.filesystem.":project_roots"]` `"**/*.env" = "deny"`; set `glob_scan_max_depth` for `**` on Linux/Windows |
| Gemini CLI | `.geminiignore` (gitignore syntax) | one pattern per line |
| Cursor | `.cursorignore` (gitignore syntax) | one pattern per line |
| GitHub Copilot | Content exclusion in repo/org settings (Business/Enterprise only), not a file | ask the repo admin; record as client-side if unavailable |
| Windsurf / Devin | `.codeiumignore` (gitignore syntax) | one pattern per line |
| OpenCode | `permission.read` map in `opencode.json` (`.env` denied by default) | `{"permission": {"read": {"*": "allow", "*.jks": "deny", "*.env.*": "deny", "*.env.example": "allow"}}}` |

Limits to state in the report: ignore files and read-deny rules usually do not cover shell commands (`cat .env`), so also deny or ask for shell reads of those paths where the tool allows it, and prefer keeping real secrets outside the repository (env vars, OS keychain, CI secrets). Verify each rule by asking the agent to read one denied file; it must refuse or fail. Mechanisms checked on 2026-10-28; re-check vendor docs if behaviour differs.

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
