---
name: pr-ready
description: Use when a {{PROJECT_NAME}} change is verified and about to become a pull request - checks the branch, commits and diff, confirms the gate and verify report match HEAD, and fills the PR description from the project's template. Stops before pushing or opening the PR.
---

# PR ready

Chat in {{CHAT_LANGUAGE}}; the PR description is in {{DOC_LANGUAGE}}. Runs in the feature worktree after `verify`. Read-only except for the description draft; never push, open the PR or post review replies unless the developer asks for that in this task.

## 1. Branch and commits

1. `git status` is clean and the branch is not {{BASE_BRANCH}}.
2. `git fetch origin {{BASE_BRANCH}}`; the branch contains the latest base (`git merge-base --is-ancestor origin/{{BASE_BRANCH}} HEAD`). If not, report it and ask whether to rebase or merge; do not rewrite pushed history on your own.
3. `git log --format='%h %an %s' origin/{{BASE_BRANCH}}..HEAD`: one logical change per commit, real author (AGENTS.md "Git"), no "wip"/"fix typo" commits left to squash. List what to squash or split; change history only with approval.

## 2. Diff hygiene

On `git diff origin/{{BASE_BRANCH}}...HEAD`:

- In scope of the ticket/spec; unrelated files listed.
- No debug leftovers: {{DEBUG_PATTERNS}}  <!-- e.g. println/Log.d added in this diff, commented-out code, TODO without a ticket, hardcoded test URLs -->
- No secrets or credential files (patterns from the `security-audit` skill), no local agentic files that must stay local (`.git/info/exclude` list), no build output.
- Baselines did not grow (`git diff --stat` on baseline files).

## 3. Evidence matches HEAD

- Quality gate `{{CMD_GATE}}` green on the current HEAD (rerun if commits changed after `verify`).
- `verify-report.md` exists for this branch and was produced at the current HEAD; otherwise run `verify` again.
- Known-red checks from AGENTS.md are named as such, not hidden.

## 4. Description

1. Template: `{{PR_TEMPLATE_PATH}}`  <!-- detect: GitHub `.github/pull_request_template.md` or `.github/PULL_REQUEST_TEMPLATE/`, GitLab `.gitlab/merge_request_templates/*.md`, Bitbucket: repository default description (ask the developer); none = What / Why / How tested / Screenshots / Risks -->
2. Fill every section from the spec, the diff and the verify report. Tick a checklist item only with evidence from this session; leave the rest unticked and say why.
3. Add: ticket link `{{TICKET_EXAMPLE}}`, test data or accounts used on {{TEST_ENVIRONMENT}} (names only), screenshots/video from the verify report, rollout or migration notes.

## 5. Hand over

Send: verdict (ready / blocked by ...), the list of fixes still needed, and the description draft as a file outside git. STOP. The developer pushes and opens the PR, or tells you to.
