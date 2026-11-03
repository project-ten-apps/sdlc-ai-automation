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

## Enforcement

Questionnaire answer 13 decides where the gate is enforced.

- **CI can block merges:** run the gate command as a required check on every PR. The hook below is still useful for faster feedback but optional.
- **No such CI:** a git `pre-push` hook is the gate. It fires on every push, whichever agent or human runs it. Template: `templates/githooks/pre-push` (replace `{{CMD_GATE}}`, keep LF line endings and the executable bit: `git update-index --chmod=+x .githooks/pre-push`).
  - Commit allowed (answer 1): commit it as `.githooks/pre-push`; each developer runs `git config core.hooksPath .githooks` once (or a build task such as `installGitHooks` does it). Add that line to AGENTS.md "Commands".
  - Local only: copy it to `.git/hooks/pre-push`. If the gate task itself cannot be committed yet, the hook runs the existing commands in sequence instead.
- **Agents must not skip it.** Deny `--no-verify` pushes for every agent that supports command rules. Claude Code, in the same settings file as the secret rules (`templates/tool-pointers.md`):

  ```json
  "deny": ["Bash(git push *--no-verify*)", "PowerShell(git push *--no-verify*)"]
  ```

  Command rules are best-effort (an agent can still change `core.hooksPath`), so also state the rule in AGENTS.md "Hard rules": never bypass hooks; a red gate goes to the developer. Verify by asking the agent to push with `--no-verify`; it must be refused.
- **Optional agent hook (Claude Code `PreToolUse`)** only if the team wants the gate output in the agent's context before git runs: matcher `Bash|PowerShell`, `"if": "Bash(git push *)"` (a second handler for `PowerShell(git push *)`), exit code 2 blocks the call. Run the gate in `cwd` from the hook's stdin JSON, not in `$CLAUDE_PROJECT_DIR`, which stays at the main checkout when the push comes from a worktree. On Windows set `"shell": "powershell"`: Gradle started from Git Bash in a sandboxed agent shell can fail with "Unable to establish loopback connection". With both hooks the gate runs twice per push; skip the git hook when a stamp file (gate passed for the current HEAD on a clean tree) matches.

## Rollout

Treat adding the gate as a build-config change: it needs approval (AGENTS.md "Needs approval") and follows the commit decision from questionnaire answer 1. Record per check: tool, scope, baseline size at introduction, runtime.
