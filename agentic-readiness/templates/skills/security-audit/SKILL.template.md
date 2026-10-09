---
name: security-audit
description: Use to audit the {{PROJECT_NAME}} repository or a feature diff for security issues against {{SECURITY_STANDARD}} and produce a severity-ranked report.
---

# Security audit ({{SECURITY_STANDARD}})

Read-only: never modify code. Never print full secret values: show the first 4 characters and `file:line`.
Report in {{DOC_LANGUAGE}}; summary to the developer in {{CHAT_LANGUAGE}}.
Use Context7 (MCP, or official docs) for security-related libraries and platform APIs.

## Scope

- **Diff mode** (default during feature/bugfix work): changed files plus what they call.
- **Full mode** (on request and during readiness setup): the whole repository, including git history for secrets.
Reuse earlier security reports if present; mark each old finding as still present / fixed.

## Checklist

1. **Secrets:** API keys, tokens, passwords, keystores/certificates, service config files, signing configs, `.env`, URLs with credentials. Full mode: scan history (`gitleaks detect` or `trufflehog git file://.` if installed, else `git log -p -S<pattern>` for common key prefixes).
2. **Storage:** tokens and PII in plain preferences, files, databases or external storage; backup/extraction rules.
3. **Network:** HTTPS only, cleartext exceptions, certificate validation overrides, pinning where required.
4. **Platform:** exported/unprotected components, deep links and intent/URL handling, WebView settings, mutable pending intents, platform permission usage vs need.
5. **Privacy:** PII or tokens in logs, analytics and crash reports.
6. **Build/release:** debug flags in release, obfuscation/minification, vulnerable or outdated dependencies ({{DEPENDENCY_AUDIT_CMD}}).
7. **Auth/session:** token lifetime and refresh, logout clears data, server-side checks not replaced by client checks.

{{STACK_SECURITY_HOTSPOTS}}

## Report

`security-report.md` outside git (e.g. `../{{REPO_DIR}}-verify/`), table: ID, severity (critical/high/medium/low), standard reference, `file:line`, issue, fix recommendation, owner (our side / client side).
Verdict line: any critical finding means the feature is NOT done.
