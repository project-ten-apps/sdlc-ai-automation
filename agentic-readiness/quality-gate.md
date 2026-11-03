# Quality gate

Agents follow written rules unevenly; rules that fail the build are followed every time. An agent-ready repository turns its conventions into one command that fails on new violations, and makes that command hard to skip. Read this file in step 3 (tools) and when planning stage 0 of step 6. Stack recipes and pitfalls are in the stack guide.

## Shape

- **One command.** A single entry point (a Gradle task, a `make`/`just` target, a script in `tool/` or `scripts/`) runs formatting check, lint/analyze, unit tests, architecture rules and release-build checks that need no signing. The same command goes into AGENTS.md, the `verify` skill, the hooks and CI. Agents and humans run the same thing.
- **Fast enough to run on every push**: aim for a few minutes warm. Leave instrumented/device tests out of it; they belong to `verify`.
- **Green on the base branch.** If a check is red on the base branch, baseline it (below) or leave it out and list it under "Known-red checks" in AGENTS.md. A gate that is red on day one gets switched off.

## Baselines

1. **Every check gets a baseline** on a legacy repository, so a failure always means new code. Keep one baseline file per check and module, committed next to the module.
2. **Baselines only shrink.** The gate should fail both on a new violation and on a baseline entry that is no longer violated ("fixed now, delete the line"). Where the tool cannot do that, add a gate step that fails when a baseline file has more lines than on the base branch.
3. **Baseline files must exist** before the first run if the tool treats a missing file as "create and fail"; keep an empty file or configure the baseline only when the file exists.
4. **Lock in good code too.** Rules with zero violations today are the cheapest to add and protect what the team already does right.

## Prove each check is real

A green check that inspects nothing is worse than no check. For every tool in the gate, confirm from its task list, report or file count that it covers the main sources (not only build scripts or tests). In full mode, make one deliberate violation in a main source file on a scratch branch, run the gate, see it fail, and discard the change.

## Rollout

Treat adding the gate as a build-config change: it needs approval (AGENTS.md "Needs approval") and follows the commit decision from questionnaire answer 1. Record per check: tool, scope, baseline size at introduction, runtime.
