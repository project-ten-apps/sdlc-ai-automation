# Readiness levels

The report scores readiness on the scale of [Factory Agent Readiness](https://docs.factory.com/agent-readiness/overview): 9 pillars, 5 levels, a repository starts at level 1 and reaches the next level when it passes at least 80% of the criteria of its current level. Pillar and level names are Factory's; the criteria below are this skill's, adapted to brownfield and mobile projects. Read this file at step 1.5 (audit) and again for "Readiness after".

Scoring rules:

- Substance over existence: a criterion passes only with evidence (command and result, file and line). An empty or stale AGENTS.md fails; a test task that runs zero tests fails.
- Mark a criterion that cannot apply (no backend, no UI) as `n/a`; it does not count toward the 80%.
- The level is the highest one whose own criteria are at 80% or more, with every lower level also at 80% or more.

## Pillars

| Pillar | What it covers here |
|---|---|
| Style & Validation | linter/analyzer, formatter, architecture rules, the quality gate |
| Build System | build command, wrappers and lockfiles, pinned SDKs, where the agent can build |
| Testing | unit, integration/instrumented, device verification, flaky tests |
| Documentation | README, AGENTS.md, tool pointers, code map, known-red list |
| Development Environment | SDK/emulator setup, env template, background long-running commands, worktree per task |
| Debugging & Observability | logs the agent can read, crash reporting, structured logging |
| Security | secrets out of the tree and history, read protection per agent, branch protection, secret scanning |
| Task Discovery | tracker keys, issue and PR templates, specs, human-only decisions |
| Product & Experimentation | analytics, feature flags, experiments |

## Criteria by level

| # | Level | Pillar | Criterion |
|---|---|---|---|
| 1.1 | 1 Functional | Documentation | README says how to build and run |
| 1.2 | 1 Functional | Build System | The agent builds the project somewhere (local, cloud sandbox, remote session, SSH host) |
| 1.3 | 1 Functional | Testing | Unit tests exist and the agent can run them |
| 1.4 | 1 Functional | Style & Validation | Linter or analyzer configured |
| 1.5 | 1 Functional | Security | No live secrets in the working tree |
| 2.1 | 2 Documented | Documentation | AGENTS.md with verified commands, known-red checks and needs-approval list, within size limits |
| 2.2 | 2 Documented | Documentation | Pointers for every agent in use; one source of truth (sync tools such as rulesync or Ruler are fine) |
| 2.3 | 2 Documented | Documentation | Code map (graphify or module map) |
| 2.4 | 2 Documented | Build System | Wrapper scripts and lockfiles committed; `.gitattributes` with `eol=lf` |
| 2.5 | 2 Documented | Security | Secret read protection per agent, verified |
| 2.6 | 2 Documented | Task Discovery | PR template; tracker key format; human-only decisions written down |
| 2.7 | 2 Documented | Development Environment | SDK, device and env setup documented (env template, no real values) |
| 3.1 | 3 Standardized | Style & Validation | One gate command, green on the base branch, with baselines |
| 3.2 | 3 Standardized | Style & Validation | Gate enforced: required CI check or pre-push hook, `--no-verify` denied |
| 3.3 | 3 Standardized | Testing | Integration/instrumented tests the agent can run |
| 3.4 | 3 Standardized | Testing | Agent verifies on a device, emulator or browser with screenshots |
| 3.5 | 3 Standardized | Security | Secret scanning in the gate or CI; branch protection on the base branch |
| 3.6 | 3 Standardized | Task Discovery | Spec-driven framework and project skills/subagents installed (`new-feature` to `pr-ready`) |
| 3.7 | 3 Standardized | Debugging & Observability | The agent can read app logs (logcat, console, server logs) during verification |
| 4.1 | 4 Optimized | Style & Validation | Gate runs in a few minutes warm; architecture rules for the team's recurring review comments |
| 4.2 | 4 Optimized | Testing | Flaky tests detected and quarantined; screenshot tests where UI matters |
| 4.3 | 4 Optimized | Debugging & Observability | Crash reporting and structured logging |
| 4.4 | 4 Optimized | Development Environment | Parallel agents isolated (worktree per task, own emulator; container-use or similar where needed) |
| 4.5 | 4 Optimized | Task Discovery | Pilot task done; its lessons are in AGENTS.md, skills and the gate |
| 5.1 | 5 Autonomous | Task Discovery | Agents take tracker tasks through the full cycle; humans only approve the spec and the PR |
| 5.2 | 5 Autonomous | Style & Validation | New review comments regularly become gate rules |
| 5.3 | 5 Autonomous | Product & Experimentation | Feature flags or experiments let agent changes ship behind a switch |

Most brownfield projects start at level 1 or 2; the skill's full mode aims for level 3, and level 4 after the pilot.

## Ready for agentic development

The final checklist in the report. Each item is `yes`, `partial` or `no` with evidence; `no` items go to "Open items".

1. The agent can build and run tests, and the report says where.
2. AGENTS.md is the single source of truth, verified and within size limits; every agent in use points to it.
3. Known-red checks are listed; nothing else is red on the base branch.
4. Secrets are out of the tree and read-protected for every agent in use.
5. One quality gate command exists and is enforced.
6. The agent verifies changes on a device, emulator or browser with evidence.
7. Project skills and subagents are installed, including `verify` and `pr-ready`.
8. Human-only decisions and the needs-approval list are agreed with the developer.
9. Git setup is safe for agents: identity, line endings, worktree per task.
10. A pilot task went through the full cycle and its lessons are applied.
