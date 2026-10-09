# Stack guide: any other stack

Use this when there is no dedicated guide. Find the equivalents and record them in AGENTS.md; add a new `stacks/<stack>.md` to this skill when a stack comes up twice.

## Detect

Manifest and lock files (`package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `*.csproj`, `Gemfile`, `composer.json`, `Package.swift`, ...), runtime version files (`.nvmrc`, `.python-version`, `global.json`, `.tool-versions`), framework, monorepo tooling, container/dev-container files.

## Find and verify

| Purpose | Look in |
|---|---|
| Install | README, CI config, manifest scripts |
| Build | manifest scripts, Makefile/Taskfile, CI |
| Test (unit / integration / e2e) | test folders, CI jobs |
| Lint / format / type check | config files (`.eslintrc*`, `ruff.toml`, `golangci.yml`, ...) |
| Dependency audit | `npm audit`, `pip-audit`, `govulncheck`, `cargo audit`, `dotnet list package --vulnerable`, `osv-scanner` |
| Run locally | README, docker-compose, launch configs |

Run each command once; a command that is documented but fails is a red audit item.

## Verification target

- Web: start the dev server and drive it with the agent's browser tool or Playwright; screenshots per step; check the console for errors.
- Backend: run the service and hit it with the integration tests or `curl` scenarios from the spec.
- CLI/library: run the test suite and a usage example from the README.

## Security

OWASP ASVS / Top 10: secrets in tree and history, `.env` files, auth/session handling, injection, SSRF, deserialization, dependency CVEs, CORS, logging of PII, debug flags in production configs.
