---
name: verify
description: Use to verify a {{PROJECT_NAME}} change end to end before a PR - quality gate, integration tests, self-review, smoke test of the spec scenarios on {{VERIFY_TARGET}}, and an evidence-based report with a PR description draft.
---

# Verification on {{VERIFY_TARGET}}

Chat in {{CHAT_LANGUAGE}}; the report file is in {{DOC_LANGUAGE}}. Runs in the feature worktree. Never commit.
Evidence before claims: every result in the report comes from a command you ran in this session.

## 1. Environment

{{ENVIRONMENT_SETUP}}
<!-- From the stack guide: SDK location, device/emulator/simulator/browser start, wait-until-ready check. If no device can be started, STOP and tell the developer what to create. -->

## 2. Automated checks

1. Quality gate: `{{CMD_GATE}}` (build, lint, unit tests, architecture rules). A red gate goes straight into the report; never edit a baseline to make it green.
   <!-- No gate yet: run build `{{CMD_BUILD}}`, static analysis `{{CMD_LINT}}` and unit tests `{{CMD_UNIT_TEST}}` instead. -->
2. Integration / instrumented tests on the target: `{{CMD_INTEGRATION_TEST}}`.
3. Collect passed / failed / skipped counts and failure messages from {{TEST_REPORT_PATHS}}.
4. Tests for new logic: every new or changed class with logic has a test in the diff (`git diff --stat {{BASE_BRANCH}}...HEAD`); list the ones without.
5. Self-review the diff against AGENTS.md conventions and {{GUIDELINES_DOCS}}; list each deviation with `file:line`.

## 3. Smoke test

1. Scenarios: the WHEN/THEN scenarios of the current spec change, plus any smoke checklist in `docs/`.
2. Install and launch the app on the target; clear logs first.
3. Drive each scenario ({{UI_DRIVER}}). Screenshot after each step.
4. After each scenario, scan logs for crashes, ANRs/hangs and errors from the app.
5. Project-specific checks tools cannot do: {{MANUAL_CHECKS}}  <!-- e.g. screenshots per locale and RTL, rotation/process recreation, back navigation, dark theme -->
6. Steps that cannot be automated (camera, real payment, external login code) are marked "manual check needed" with the reason, never silently skipped.

## 4. Report

Save `verify-report.md` with screenshots outside git (e.g. `../{{REPO_DIR}}-verify/<branch>-<date>/`) and send a short summary:

- One-line verdict: ready / failures / manual check needed.
- Gate and integration tests: counts and failed tests with causes; logic without tests; guideline deviations.
- Smoke: table of scenario, result, screenshot.
- Crashes and errors from logs.
- What to check manually and why.
- PR description draft: what changed, how it was tested, test data or accounts for {{TEST_ENVIRONMENT}} (names only, never secrets), screenshots.
