---
name: agentic-readiness
description: Use when preparing an existing codebase (Android/Kotlin, Flutter/Dart or any other stack) for agentic AI development - questionnaire, readiness audit, AGENTS.md and code map, tooling, security audit, project skills and subagents, migration plan, pilot task. Works with any coding agent that reads Agent Skills or AGENTS.md.
license: MIT
metadata:
  version: "1.1.0"
---

# Agentic readiness

Prepare an existing repository so that coding agents (Claude Code, Codex, Gemini CLI, Cursor, Copilot, OpenCode, ...) can work in it safely and productively.

Talk to the developer in their language. Every file you create (AGENTS.md, specs, skills, subagents, reports) is written in English unless the questionnaire says otherwise.

Paths below are relative to this skill's folder. Read a supporting file only when you reach the step that needs it.

## Capability notes (tool-neutral)

- "Ask the developer" = use your structured question tool if you have one, otherwise ask in chat and wait.
- "Subagents" = use them if your agent supports subagents/custom agents; otherwise run the same role prompts sequentially yourself.
- "MCP" = use an MCP server if your agent supports MCP; otherwise use the CLI or official docs listed as the fallback.
- Never assume a vendor-specific tool exists. Check, then fall back.

## Modes

- **Full** (default): steps 0-7.
- **Audit only** (read-only): use when the developer asks to "assess", "audit", "check readiness", or when the client has not approved agentic work yet. Run step 0 (questions 1, 4, 11 only), step 1 and the read-only checks of step 4. Do not create, edit or install anything in the repository or the user's tool config; write only the report, outside the repository (e.g. `../<repo>-agentic/agentic-readiness-report.md`). Skip sections 2, 3, 5, 6, 7 of the report except a short "Recommended next steps" list.

## 0. Questionnaire - the only stop before work

Ask the questions in `questionnaire.md` once, offering the defaults. Record the answers in `agentic-readiness-report.md` (template: `templates/reports/agentic-readiness-report.md`). Then proceed without further stops until step 7, except where a step says STOP.

## 1. Audit

1. Detect the stack and versions from build files. Load the matching guide: `stacks/android.md`, `stacks/flutter.md`, or `stacks/generic.md` for anything else.
2. Check: existing AGENTS.md / CLAUDE.md / GEMINI.md / `.cursor/rules` / `.github/copilot-instructions.md`; tests (count, kinds, do they pass); CI; linters/formatters; build reproducibility (wrapper scripts and lockfiles committed?); secrets in the tree and in git history; branch divergence (main vs active feature branches, unmerged work).
3. Instruction size (context hygiene): count lines of every existing instruction file and skill. Green: AGENTS.md/CLAUDE.md up to 200 lines, each skill up to ~15 steps and 500 lines. Amber: instruction file 200-500 lines or skills mixing several workflows. Red: over 500 lines, or one file describing the whole organisation. Apply the same limits to everything you generate later.
4. Fill in the audit section of the report: red/amber/green per area plus the gap list.

## 2. Project instructions and code map

1. Build the code map with **graphify** (skill or CLI, output in `graphify-out/`, gitignored). If graphify is unavailable, say so in the report and produce a module map from the build files and directory tree instead; never invent structure.
2. Write `AGENTS.md` from `templates/AGENTS.md`: stack, module map, key flows, exact build/test/lint commands (verified by running them), conventions, hard rules from the questionnaire, tools section.
3. Add thin per-tool pointers so every agent reads the same AGENTS.md (see `templates/tool-pointers.md`): `CLAUDE.md` importing it (`templates/CLAUDE.md`), and only for the tools the team uses, `GEMINI.md`/settings, Copilot and Cursor pointers.

## 3. Tools

Install and verify the tools from the stack guide at the scope the questionnaire allows (project-shared only if committing is allowed, otherwise user or local scope).

- All stacks: Context7 (MCP, or `npx ctx7` / official docs as fallback) for current library and API docs; the spec-driven framework chosen in the questionnaire (default OpenSpec: `npm i -g @fission-ai/openspec`, `openspec init`).
- Stack-specific tools: see the stack guide.

Verify each tool with one real call (list servers, run a sample query) and record the result.

## 4. Security

Run the full mode of `templates/skills/security-audit/SKILL.template.md` (OWASP MASVS for mobile, OWASP ASVS/Top 10 otherwise): secrets, keystores, signing configs, service config files, `.env`, git history. Record findings with severity and owner (our side / client side) and a short remediation plan. If anything is critical, draft a short message to the client explaining the risk and the proposed fix. Never print full secret values (first 4 characters + `file:line`).

## 5. Project process: skills and subagents

1. Generate project skills from `templates/skills/*/SKILL.template.md`: replace every `{{PLACEHOLDER}}` with values from AGENTS.md and the stack guide; delete sections that do not apply; save each as `<skills-dir>/<name>/SKILL.md`. Prefix names with the project key where a generic name could clash with the developer's global skills (e.g. `acme-code-review`).
2. Generate subagents from `templates/agents/*.md` for the tools in use (see `templates/tool-pointers.md` for each tool's folder and format): spec-writer, developer, code-reviewer, security-reviewer (mandatory, read-only), qa-verifier.
3. Flow: spec-writer -> human approval of the spec -> developer (strict TDD) -> code-reviewer and security-reviewer in parallel -> qa-verifier -> report.
4. Location: `.agents/skills/` (plus each tool's own folder if it does not read `.agents/skills`) only if committing is allowed; otherwise keep them local and list them in `.git/info/exclude`.

## 6. Stack and migration plan

Document the current stack (versions, code metrics, language split), risks, and a staged migration:

- Stage 0, build foundation: wrapper/pinned SDK, secrets out of the build, version catalog or lockfile, linters with a baseline, test infrastructure, CI.
- Then architecture and dependency upgrades; UI modernisation last.
- New features go straight to the target architecture.

Estimate each stage in agent hours plus human review hours, and state that estimates are derived, not measured.

## 7. Pilot

STOP and ask the developer for one real task. Run it through the full cycle (`new-feature` or `bugfix`). Record what slowed the agent down, then update AGENTS.md and the skills. Final report: readiness before/after, what is left, what needs the client.

## Validate the report

Before handing over any report (audit-only or full), run the validator and fix every error it lists:

- Windows: `pwsh <skill-dir>/scripts/validate-report.ps1 -Path <report> [-Mode Audit] [-ProjectRoot <repo>]`
- macOS/Linux: `sh <skill-dir>/scripts/validate-report.sh <report> [audit|full] [<repo>]`

It checks that required sections exist and are filled, no `{{PLACEHOLDER}}` is left, every audit row has a red/amber/green status, and (with the project root) that AGENTS.md/CLAUDE.md stay within the size limits.

## Rules

- Respect the commit decision from step 0 everywhere. When in doubt, keep it local (`.git/info/exclude`, local/user scope settings).
- Never print or copy full secret values.
- One worktree per work stream, so local agentic files do not leak into feature branches.
- Evidence before claims: every "passes", "works", "installed" in a report comes with the command and its output summary.
