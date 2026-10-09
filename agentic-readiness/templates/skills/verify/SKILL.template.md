---
name: verify
description: Use to verify a {{PROJECT_NAME}} change end to end - build, unit and integration tests, smoke test of the spec scenarios on {{VERIFY_TARGET}}, and an evidence-based report for the developer.
---

# Verification on {{VERIFY_TARGET}}

Chat in {{CHAT_LANGUAGE}}; the report file is in {{DOC_LANGUAGE}}. Runs in the feature worktree. Never commit.
Evidence before claims: every result in the report comes from a command you ran in this session.

## 1. Environment

{{ENVIRONMENT_SETUP}}
<!-- From the stack guide: SDK location, device/emulator/simulator/browser start, wait-until-ready check. If no device can be started, STOP and tell the developer what to create. -->

## 2. Automated checks

1. Build: `{{CMD_BUILD}}`. A build failure goes straight into the report.
2. Static analysis: `{{CMD_LINT}}`.
3. Unit tests: `{{CMD_UNIT_TEST}}`.
4. Integration / instrumented tests on the target: `{{CMD_INTEGRATION_TEST}}`.
5. Collect passed / failed / skipped counts and failure messages from {{TEST_REPORT_PATHS}}.

## 3. Smoke test

1. Scenarios: the WHEN/THEN scenarios of the current spec change, plus any smoke checklist in `docs/`.
2. Install and launch the app on the target; clear logs first.
3. Drive each scenario ({{UI_DRIVER}}). Screenshot after each step.
4. After each scenario, scan logs for crashes, ANRs/hangs and errors from the app.
5. Steps that cannot be automated (camera, real payment, external login code) are marked "manual check needed" with the reason, never silently skipped.

## 4. Report

Save `verify-report.md` with screenshots outside git (e.g. `../{{REPO_DIR}}-verify/<branch>-<date>/`) and send a short summary:

- One-line verdict: ready / failures / manual check needed.
- Build, analysis, unit, integration: counts and failed tests with causes.
- Smoke: table of scenario, result, screenshot.
- Crashes and errors from logs.
- What to check manually and why.
