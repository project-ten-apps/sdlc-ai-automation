# Agentic readiness report - {{PROJECT_NAME}}

Date: {{DATE}} | Branch: {{BRANCH}} | Agent(s): {{AGENTS_USED}} | Mode: {{MODE}}  <!-- full / audit -->

## Questionnaire answers

| # | Question | Answer |
|---|---|---|
| 1 | Commit agentic files? | |
| 2 | Documentation language | |
| 3 | Chat language | |
| 4 | Coding agents in use | |
| 5 | Tracker / key format | |
| 6 | Spec-driven framework | |
| 7 | TDD | |
| 8 | Branches | |
| 9 | Approval stops | |
| 10 | Verification device | |
| 11 | Client concerns | |
| 12 | Tool install scope | |
| 13 | Video evidence | |
| 14 | CI that can block merges | |

## Audit (before)

| Area | Status | Evidence | Gap / action |
|---|---|---|---|
| Agent instructions (AGENTS.md etc.) | red/amber/green | | |
| Build reproducibility | | | |
| Tests (count, pass rate) | | | |
| CI | | | |
| Lint / format | | | |
| Executable rules (single gate, enforced) | | | |
| Secrets | | | |
| Secret read protection (per agent) | | | |
| Agent can build and test (where: local / cloud sandbox / remote session / SSH host) | | | |
| Git identity and line endings | | | |
| Code map / docs | | | |
| Instruction size (context hygiene) | | | |
| Branch hygiene | | | |
| Verification device | | | |

## Readiness level

Scale and criteria: `readiness-levels.md` (Factory's 9 pillars and 5 levels, 80% of a level's criteria to reach it).

Level: N (name)  <!-- e.g. "Level: 2 (Documented)" -->

| Level | Passed | Applicable | % |
|---|---|---|---|
| 1 Functional | | | |
| 2 Documented | | | |
| 3 Standardized | | | |
| 4 Optimized | | | |
| 5 Autonomous | | | |

Failed criteria (by number): ...

## Tools installed

| Tool | Scope | Verified by | Result |
|---|---|---|---|

## Security summary

See `security-report.md`. Critical: N, High: N, Medium: N, Low: N. Client-side items: ...

## Generated files

| File | Committed or local |
|---|---|

## Migration plan

| Stage | Scope | Agent hours | Human review hours | Risks |
|---|---|---|---|---|

Estimates are derived from code size and comparable tasks, not measured.

## Pilot (after)

Task: | Result: | What slowed the agent down: | Changes made to AGENTS.md / skills:

## Readiness after

Same table as the audit, with the new status, and the new readiness level: `Level: N (name)`.

## Ready for agentic development

| # | Item | Status | Evidence |
|---|---|---|---|
| 1 | Agent builds and runs tests (where) | | |
| 2 | AGENTS.md single source, verified, within limits; pointers for every agent | | |
| 3 | Known-red listed; nothing else red on base | | |
| 4 | Secrets out of the tree and read-protected per agent | | |
| 5 | One quality gate command, enforced | | |
| 6 | Agent verifies on device/emulator/browser with evidence | | |
| 7 | Project skills and subagents installed (incl. verify, pr-ready) | | |
| 8 | Human-only decisions and needs-approval list agreed | | |
| 9 | Git safe for agents: identity, line endings, worktree per task | | |
| 10 | Pilot task done, lessons applied | | |

Status: yes / partial / no. Every `no` goes to "Open items".

## Recommended next steps

## Open items / needs the client
