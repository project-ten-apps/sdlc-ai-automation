# Stack guide: Flutter / Dart

## Detect

- `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, `.fvmrc` / `.fvm/fvm_config.json`, `android/`, `ios/`, `web/`, `macos/`, `windows/`, `linux/`, `melos.yaml` (monorepo).
- Record: Flutter and Dart SDK versions (pinned via FVM?), target platforms, state management (Bloc/Riverpod/Provider/GetX/other), routing (go_router/auto_route/Navigator), DI (get_it/injectable/riverpod), networking (dio/http), persistence, code generation (build_runner, freezed, json_serializable), flavors, native code in `android/` and `ios/`.

## Commands (prefix with `fvm` if the repo pins a version; verify each)

| Purpose | Command |
|---|---|
| Dependencies | `flutter pub get` |
| Code generation | `dart run build_runner build --delete-conflicting-outputs` (if used) |
| Analyze | `flutter analyze` |
| Format check | `dart format --output=none --set-exit-if-changed .` |
| Unit + widget tests | `flutter test` (coverage: `flutter test --coverage`) |
| Integration tests | `flutter test integration_test` on a running emulator/simulator |
| Outdated / deps | `flutter pub outdated`, `dart pub deps` |
| Build | `flutter build apk --debug` / `flutter build ios --no-codesign` (macOS only) |

## Tools

- **Dart / Flutter MCP server** (if your agent supports MCP; ships with recent Dart SDK as `dart mcp-server`): analysis, runtime errors, hot reload, widget tree. Fallback: CLI commands above.
- **Context7**: Flutter, Dart and package docs (pub.dev).
- **FVM** if `.fvmrc` exists or the team needs a pinned SDK.
- Lints: `flutter_lints` or `very_good_analysis`; baseline existing issues (temporary `analyzer: errors:` / `exclude:` entries with a TODO, or a list of ignored rules) so new code is held to the full rule set.
- Dependency audit: `flutter pub outdated`; check advisories on pub.dev / OSV (`osv-scanner --lockfile=pubspec.lock` if installed).

## Device verification

- Android emulator: see `android.md` (adb, AVD). iOS simulator (macOS): `xcrun simctl list`, `open -a Simulator`.
- Integration tests are the main smoke vehicle: drive scenarios from the spec with `integration_test` + `flutter_test` finders; take screenshots via `IntegrationTestWidgetsFlutterBinding.takeScreenshot` or `adb exec-out screencap`.
- Check `flutter logs` / logcat for uncaught exceptions and `FlutterError`.

## Security hotspots

Everything in `android.md` for `android/`, plus `ios/Runner/GoogleService-Info.plist`, `Info.plist` (ATS exceptions `NSAllowsArbitraryLoads`), `ios/` signing/provisioning files, `.env` loaded via `flutter_dotenv` (bundled into the app = not secret), `--dart-define` values in scripts/CI, keys in Dart constants, `shared_preferences` holding tokens (use `flutter_secure_storage`), `print`/`debugPrint` with PII, obfuscation for release (`--obfuscate --split-debug-info`).

## Migration notes

Typical stage 0: pin SDK with FVM, commit `pubspec.lock` for apps, lints with baseline, test folders and helpers (mocktail/mockito, golden tests if UI-heavy), CI running analyze + test. Then: null-safety/Dart 3 leftovers, state-management consolidation, routing to go_router, dependency upgrades (`flutter pub upgrade --major-versions` in small batches).
