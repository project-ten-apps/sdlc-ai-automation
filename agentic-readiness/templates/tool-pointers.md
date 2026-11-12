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

## Claude Code security plugins

Two plugins from the official marketplace `claude-plugins-official` (GitHub `anthropics/claude-plugins-official`, built into Claude Code). Both need Python 3.9+ on `PATH`.

- `claude-security`: on-demand multi-agent vulnerability scan and verified patches (`/claude-security`). Costs tokens only when someone runs it. **Always enable** for Claude Code users.
- `security-guidance`: warnings on risky edits, an LLM review of the diff at the end of every turn, an agentic review on every `git commit`. It adds a model call to every turn and commit, so it is **recommended, not default**: assess the project, then let the developer choose.

### Assess security-guidance for this project

Use the step 1 audit and step 4 findings. Its checks target web-style vulnerabilities (injection, XSS, SSRF, IDOR, auth bypass, unsafe deserialization, path traversal, hardcoded secrets).

| Relevance | Signals in the repository |
|---|---|
| High | Backend or web app taking untrusted input (HTTP handlers, SQL/ORM, templates, file uploads, URL fetching); auth, payments or personal data; WebViews or deep links passing data to code; secrets already found in step 4; a regulated client (question 11) |
| Medium | Mobile or desktop client that talks to an API but holds no server logic; internal tools; CLI tools that parse files or run shell commands |
| Low | Libraries without I/O, docs, pure UI prototypes, scripts nobody runs on untrusted data |

### Ask the developer

One question, with your recommendation first and the reason taken from the signals you found (e.g. "High: Retrofit + WebView with JS bridge in `app/web/`, 2 secrets in step 4"):

1. **Enable for the whole team** (shared `.claude/settings.json`): every turn and commit is reviewed; extra tokens for everyone. Recommend for High.
2. **Enable only for me** (`.claude/settings.local.json`): try it on this machine first; the team decides after the pilot. Recommend for Medium.
3. **Do not enable**: rely on the `security-reviewer` subagent, `security-audit` skill and `/claude-security` scans. Recommend for Low.

Option 1 needs commit permission (question 1); if answer 1 is "local", offer only 2 and 3. Record the choice and the reason in the report ("Security summary") and in AGENTS.md "Tools".

### Where to write it

| Scope | File | Effect |
|---|---|---|
| Team (commit allowed) | `.claude/settings.json` | Enabled for everyone who opens the repo, but not installed: each developer runs `claude plugin install <name>@claude-plugins-official --scope project` once (or `--scope user` for all projects). Put the commands in AGENTS.md "Tools". |
| Local | `.claude/settings.local.json` (untracked) | Claude Code installs the plugins on the next start |
| Machine | `~/.claude/settings.json` via `install.ps1` | `claude-security` by default; `-Plugins claude-security,security-guidance` adds both |

```json
{
  "extraKnownMarketplaces": {
    "claude-plugins-official": {
      "source": { "source": "github", "repo": "anthropics/claude-plugins-official" }
    }
  },
  "enabledPlugins": {
    "claude-security@claude-plugins-official": true,
    "security-guidance@claude-plugins-official": true
  }
}
```

Keep the `security-guidance` line only if the developer chose it. Merge the keys into the existing file; never drop other keys. `extraKnownMarketplaces` only matters where the built-in marketplace is missing, and applies after the developer trusts the folder. A developer opts out on their machine with `false` in `.claude/settings.local.json`. Verify with `/plugin` (plugins listed, nothing in the Errors tab). Checked against the Claude Code docs on 2026-11-12.

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
