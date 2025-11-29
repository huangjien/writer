# Writer

A Flutter application for reading novels with Supabase-backed storage, localization, and Text-To-Speech (TTS) support.

## Overview
- Reads chapters stored in Supabase and supports local Markdown imports.
- Saves reading progress and supports authenticated progress sync.
- Provides TTS playback with locale mapping and configurable settings.
- Ships with Makefile targets to simplify development and release builds across platforms.

## Prerequisites
- Flutter SDK installed (`flutter --version`).
- Platform toolchains as needed:
  - Android: Android SDK/NDK, Java, Gradle via Flutter.
  - iOS/macOS: Xcode (ensure iPhoneOS platform runtime is installed), CocoaPods.
  - Windows/Linux: respective build toolchains.
- Node.js 18+ for data import scripts.

## Setup
- Install dependencies: `make deps`
- Optional static analysis and formatting: `make analyze` and `make format`
- Environment variables for runtime (pass via dart-define at build/run time):
  - `SUPABASE_URL` – your Supabase project URL.
  - `SUPABASE_ANON_KEY` – your Supabase anonymous client key.
- Never commit secrets. Use `.env` locally and pass via Makefile variables if needed.

### Supabase configuration (embedded at build time)
- End users do not enter Supabase settings; the app reads compile-time values from `lib/state/supabase_config.dart`:
  - `supabaseUrl = String.fromEnvironment('SUPABASE_URL')`
  - `supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY')`
  - `supabaseEnabled` is `true` only when both are provided.
- If these are omitted at build time, Supabase-dependent features are disabled but the app still runs.
- The `anon` key is public by design and can be embedded in client apps; enforce data protection via Supabase Row Level Security (RLS) policies. Never embed the `service_role` key in the app.

## Supabase Import (Markdown → novels/chapters)
- Script: `scripts/import_novel_from_md.js`
- Expected directory layout:
  - Chapter files named `<number>_<title>.md` inside a `chapters/` folder.
  - Example: `001_Beginning.md`, `002_Chapter Two.md`, etc.
- Usage:
  - `cd writer`
  - `npm run import-novel -- --novel-title "Your Novel" --author "Author Name" --dir "/absolute/path/to/novel" --lang "zh-CN"`
  - Requires `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` in the environment (service role key is required to bypass RLS for inserts).
- Notes:
  - Re-running the importer upserts chapters (no duplicates).
  - Service role key must be kept server-side only; never bundle into client apps.

## Development
- Web (local dev server): `make dev-web WEB_PORT=5500 SUPABASE_URL=... SUPABASE_ANON_KEY=...`
- Chrome device: `make dev-chrome SUPABASE_URL=... SUPABASE_ANON_KEY=...`
- macOS device: `make macos SUPABASE_URL=... SUPABASE_ANON_KEY=...`

## Tests
- Run tests with coverage summary: `make test`

### Attach Supabase token to backend requests
- Obtain the access token from the current Supabase session:
  - `final token = Supabase.instance.client.auth.currentSession?.accessToken;`
- Send it in the `Authorization` header (`Bearer` scheme) when calling the backend:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

Future<http.Response> callBackend(Uri url) async {
  final token = Supabase.instance.client.auth.currentSession?.accessToken;
  final headers = {
    if (token != null) 'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };
  return http.get(url, headers: headers);
}
```

- The backend verifies this token via Supabase (`/auth/verify`). Requests without a token or with an invalid token receive `401 Unauthorized`.

## Build Targets
- Web (release): `make build-web SUPABASE_URL=... SUPABASE_ANON_KEY=...`
- Serve built web: `make serve-web-build WEB_PORT=8080`
- Android (APK release): `make build-android`
  - Automatically runs a plugin patch to ensure `isar_flutter_libs` compiles with SDK 36.
- Android (AAB for Play Console):
  - `flutter build appbundle --release --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your_anon_key`
- Android (APK direct install):
  - `flutter build apk --release --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your_anon_key`
- iOS (Xcode project, no codesign): `make build-ios`
- iOS (IPA):
  - Signed: `make build-ipa SUPABASE_URL=... SUPABASE_ANON_KEY=...`
  - No codesign: `make build-ipa-nocodesign`
- Desktop:
  - macOS: `make build-macos`
  - Windows: `make build-windows`
  - Linux: `make build-linux`

## Platform Notes
- Android
  - The project patches `isar_flutter_libs` Gradle (`scripts/patch_isar.js`) to set `compileSdkVersion 36` and fix resource linking errors (e.g., `android:attr/lStar`).
  - If you run `flutter pub upgrade` and the plugin cache changes, the Makefile pre-step re-applies the patch before Android builds.
  - Package name/namespace: update `android/app/build.gradle.kts` (`namespace`) and `AndroidManifest.xml` before publishing. Current namespace: `com.example.writer`.
- iOS
  - Xcode 16 requires installing the iOS platform runtime (e.g., iPhoneOS 26.0). Install from `Xcode → Settings → Platforms`.
  - For device builds and App Store distribution, configure signing in `Runner.xcworkspace` and use `build-ipa`.

## Icons & Branding
- Web icons and favicon are located under `web/` and `web/icons/`.
- These are currently replaced with assets from `/Users/huangjien/workspace/writer/assets/`:
  - `icon-192x192.png` → `web/icons/Icon-192.png`, `web/icons/Icon-maskable-192.png`
  - `icon-512x512.png` → `web/icons/Icon-512.png`, `web/icons/Icon-maskable-512.png`
  - `favicon.png` → `web/favicon.png`, `favicon.ico` → `web/favicon.ico`
- If you’d like unified app icons across mobile/desktop, consider adding `flutter_launcher_icons` to `pubspec.yaml` and generating platform icons from a single source image.

## Troubleshooting
- Android resource linking error (`android:attr/lStar not found`)
  - Ensure the isar plugin is patched (`make build-android` triggers it).
  - If necessary, run `node scripts/patch_isar.js`, then `make clean`, and rebuild.
- Supabase RLS errors during import
  - Confirm you are using `SUPABASE_SERVICE_ROLE_KEY` (not `anon`) for the importer.
  - Decode the JWT to verify `role` is `service_role`.
- iOS platform not installed
  - Install the iOS platform runtime in Xcode as noted above.

- Windows plugin CMake parse error (`flutter_tts`)
  - Some versions of `flutter_tts` include CMake script constructs that break generation on certain runners.
  - CI removes `flutter_tts` from the Windows plugin list before building to ensure successful generation. If you need TTS on Windows locally, pin a compatible plugin version or exclude it for Windows.

## Useful Commands
- Print environment passed to builds: `make env-print`
- Clean Flutter build outputs: `make clean`

## CI
- Workflow: `.github/workflows/ci.yml`
  - Triggers on push, pull_request, and manual dispatch.
  - Sets up Flutter (stable), caches pub packages, runs `make lint`, and executes tests.
  - Builds and publishes installers to GitHub Releases using the version from `writer/package.json`:
    - Android: `app-release.apk` and `app-release.aab`.
    - iOS: unsigned `.ipa` when available; otherwise zips `Runner.app` as a fallback.
    - macOS: zipped `.app` bundle.
    - Windows: zipped `Release` folder.
  - Release publishing is skipped for `pull_request` events.
  - Android CI patches `isar_flutter_libs` to add `namespace` and set `compileSdkVersion 36`.
  - `flutter_tts` is pinned to a Windows-compatible version (`4.0.2`) in `pubspec.yaml` to ensure the plugin’s CMake integrates cleanly on CI.
  - To embed Supabase values in CI builds, store `SUPABASE_URL` and `SUPABASE_ANON_KEY` as repository secrets and pass them via `--dart-define` in the build commands if needed.

## Security
- Treat `SUPABASE_ANON_KEY` as a public client key; enforce access using RLS policies and authentication in Supabase.
- Never store or ship `service_role` keys in the app or in public repos. Use them only server-side or in secure CI contexts for admin tasks (e.g., imports).

## Notes
- TTS locale mapping is covered by tests (`test/tts_locale_mapping_test.dart`). The task “Map app language preference to TTS language code” is tracked in `tasks.md` and can be extended if new locales are added.
