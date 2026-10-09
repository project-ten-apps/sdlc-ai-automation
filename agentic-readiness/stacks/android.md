# Stack guide: Android / Kotlin / JVM

## Detect

- `settings.gradle(.kts)`, `build.gradle(.kts)`, `gradle/libs.versions.toml`, `gradle/wrapper/gradle-wrapper.properties`.
- Record: AGP, Gradle, Kotlin, JDK, compileSdk/targetSdk/minSdk, Java vs Kotlin split (file counts / LOC), UI toolkit (Views/XML vs Compose), DI (Hilt/Koin/Dagger/none), async (coroutines/RxJava/callbacks), networking, persistence, modules.

## Commands (verify each and record in AGENTS.md)

| Purpose | Command (Windows: `gradlew.bat`) |
|---|---|
| Build | `./gradlew assembleDebug` |
| Unit tests | `./gradlew testDebugUnitTest` |
| Instrumented tests | `./gradlew connectedDebugAndroidTest` (emulator running) |
| Lint | `./gradlew lint`; detekt / ktlint if configured |
| Dependencies | `./gradlew :app:dependencies`, `./gradlew dependencyUpdates` if the plugin exists |

If `gradlew` scripts are missing or gitignored, flag it as a red item (build not reproducible) and copy them locally from a known-good checkout; do not commit unless allowed.

## Tools

- **maven-mcp** (MCP, github.com/kirich1409/maven-mcp): latest versions, CVEs, AGP/Gradle/Kotlin compatibility, dependency conflicts. Fallback: Maven Central search + Gradle `dependencyUpdates`.
- **Context7**: AndroidX, Compose, Retrofit, etc. docs.
- **Android SDK**: `ANDROID_HOME` / `ANDROID_SDK_ROOT`, else `%LOCALAPPDATA%\Android\Sdk` (Windows) or `~/Library/Android/sdk` (macOS). Need `platform-tools/adb`, `emulator/emulator`.
- Linters: add detekt/ktlint with a **baseline** so existing issues do not block work.

## Emulator verification

1. `adb devices`; if empty: `emulator -list-avds`, `emulator -avd <name> -no-snapshot-save`, `adb wait-for-device`, poll `adb shell getprop sys.boot_completed` until `1`. No AVD -> STOP, ask the developer to create one.
2. `adb install -r <apk>`, `adb logcat -c`, launch: `adb shell monkey -p <package> 1`.
3. Drive UI with `adb shell input tap|text|swipe`, find elements via `adb shell uiautomator dump` + `adb pull /sdcard/window_dump.xml`.
4. Screenshot each step: `adb exec-out screencap -p > step-N.png`.
5. After each scenario: scan logcat for `FATAL EXCEPTION`, `ANR`, errors from the package.

## Security hotspots

`*.jks`/`*.keystore`, `signingConfigs` and passwords in `build.gradle`/`gradle.properties`, `google-services.json`, API keys in `BuildConfig`/`strings.xml`/code, `AndroidManifest.xml` (exported components, `allowBackup`, `usesCleartextTraffic`, `debuggable`), `network_security_config.xml`, WebView settings, `Log.*` with PII, ProGuard/R8 off in release.

## Migration notes

Typical stage 0: commit wrapper, move secrets to `local.properties`/CI secrets, version catalog, detekt+ktlint baseline, JUnit/MockK/Turbine + Espresso/Compose test infra, CI running unit tests. Then: Java -> Kotlin for touched files, callbacks/Rx -> coroutines, DI, Views -> Compose screen by screen.
