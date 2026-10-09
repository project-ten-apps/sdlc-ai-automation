@AGENTS.md

<!--
Claude Code reads CLAUDE.md, not AGENTS.md. The import above pulls AGENTS.md in,
so AGENTS.md stays the single source of truth. Add below ONLY what is specific
to Claude Code (keep it short).
-->

## Claude Code specifics

- Project skills: `.claude/skills/` (mirror of `.agents/skills/`). Subagents: `.claude/agents/`.
- Use the Context7 MCP server for library docs; use plan mode for multi-file changes.
