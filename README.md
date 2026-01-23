# Writer

A Flutter application for reading novels with localization and Text-To-Speech (TTS) support.

## Overview
- Reads novels/chapters from the backend and supports offline caching.
- Saves reading progress.
- Provides TTS playback with locale mapping and configurable settings.
- Ships with Makefile targets to simplify development and release builds across platforms.

## Recent UI Updates
- Home AppBar uses a logo that opens the sidebar on tap.
- Home sidebar includes: Settings, Character Templates, Scene Templates, Prompts, New Novel, About.
- About page shows a large logo above the title.
- AI Coach (Snowflake) panel keeps chat history for the current session and persists per-novel coaching state.
- Editor enhancements: formatting toolbar, markdown preview, writing stats (word/char/read time + streak), Zen mode, focus timer, and writing prompts.
- UI polish does not require `flutter_animate`/`lottie`/`confetti`/`shimmer`; shimmer uses `skeletonizer` and confetti is implemented in-app.

## Design System (UI/UX Rules)

This app uses a token-driven design system to keep the Writer UI visually and functionally consistent.

### 1) Component hierarchy and organization
- Prefer `ThemeData` for global look-and-feel (buttons, inputs, dialogs, nav) over per-screen styling.
- Prefer shared primitives in `lib/shared/widgets/` over bespoke one-off components in screens.
- When adding new UI, reuse an existing primitive or extend it; avoid duplicating variants.

### 2) Color schemes and typography
- Use `ColorScheme` and tokenized semantic colors in `lib/theme/design_tokens.dart` (avoid hard-coded `Colors.*` for UI).
- Typography is controlled by theme and typography presets; do not set ad-hoc font sizes in screens unless it’s content-specific.

#### Color Themes (managed by Theme Factory)
- Settings → Color Theme options are generated from the Theme Factory definitions in `lib/theme/themes.dart` (`themeFactoryThemes`).
- To add/modify a theme: update `themeFactoryThemes` with its name + palette colors, then run `make test` to verify switching and previews.
- Current themes:
  - Ocean Depths
  - Sunset Boulevard
  - Forest Canopy
  - Modern Minimalist
  - Golden Hour
  - Arctic Frost
  - Desert Rose
  - Tech Innovation
  - Botanical Garden
  - Midnight Galaxy

## Chinese Typography & Fonts
- Embedded Chinese font: `assets/fonts/NotoSansSC-{Regular,Bold}.ttf` (family: `Noto Sans SC`, declared in `pubspec.yaml`).
- Initialization preload: `lib/main.dart` preloads the embedded Chinese font to reduce first-render tofu/FOUT.
- Fallback chain: `lib/theme/font_packs.dart` applies a platform-aware CJK fallback list to the app `TextTheme` (even when using Inter/Merriweather).
- Custom font picker: Settings → Typography only shows curated CJK-capable font families (plus the embedded font).

### Supported Chinese fonts (fallback and picker)
- Apple: `PingFang SC`, `Hiragino Sans GB`, `Heiti SC`, `Songti SC`
- Windows: `Microsoft YaHei`, `Microsoft YaHei UI`, `Microsoft JhengHei`, `SimSun`, `SimHei`
- Linux/Android: `Noto Sans CJK SC`, `Noto Sans CJK`, `WenQuanYi Micro Hei`, `AR PL UMing CN`, `AR PL UKai CN`
- Embedded: `Noto Sans SC`

### Web embedding details
- `web/index.html` declares `@font-face` for `Noto Sans SC` and preloads the `.ttf` files with `font-display: swap`.

### Font subsetting (optional)
- If bundle size becomes a concern, subset the embedded font and replace the `assets/fonts/*` files + `pubspec.yaml` entries.
- One common approach is `fonttools` (`pyftsubset`) to produce a reduced `woff2/ttf` containing only needed Unicode ranges.

### Cross-platform rendering checklist
- Desktop browsers: Chrome, Firefox, Safari, Edge
- OS: Windows, macOS, Linux
- Mobile: iOS Safari, Android Chrome
- Verify: mixed Latin + Chinese + punctuation, bold text, and long paragraphs in Reader/Editor screens

### 3) Spacing and layout principles
- Use spacing/radius tokens (`Spacing.*`, `Radii.*`, `MobileSpacing.*`) for padding, gaps, and corner rounding.
- Maintain minimum tap targets (`MobileSpacing.touchTargetMin`) for interactive controls.

### 4) Interactive behaviors and animations
- Use shared motion tokens (`Motion.*`) for transitions and repeating animations.
- Follow the app motion preference (reduce motion disables page transitions via theme builder).

### 5) Error states and validation patterns
- Inputs use the app `InputDecorationTheme` for focus/error borders and fill colors.
- Error UX should follow the same pattern: clear message, optional retry, and no layout shifts where possible.

### Reusable component catalog (canonical)
- Buttons: `lib/shared/widgets/app_buttons.dart` (`AppButtons.primary/secondary/text/icon`)
- Form controls: `ThemeData.inputDecorationTheme`, `CheckboxThemeData`, `SwitchThemeData`
- Loading: `lib/shared/widgets/loading_state.dart` (`LoadingState`)
- Empty/error: `lib/shared/widgets/empty_state.dart`, `lib/shared/widgets/error_view.dart`
- Notifications: `lib/shared/widgets/feedback/enhanced_toast.dart` (`showEnhancedToast`), `SnackBarThemeData`
- Modals: `DialogThemeData`, `lib/shared/widgets/mobile_bottom_sheet.dart`
- Navigation: `NavigationBarThemeData`, `lib/shared/widgets/mobile_bottom_nav_bar.dart`

### Accessibility baseline (WCAG 2.1 AA)
- Use theme-driven contrast (avoid custom low-contrast grays).
- Ensure touch targets meet the minimum size and provide semantics/labels for icon-only controls (tooltip where appropriate).
- Prefer `FilledButton/OutlinedButton/TextButton` and `InputDecorationTheme` so focus and disabled states remain consistent.

## Prerequisites
- Flutter SDK installed (`flutter --version`).
- Platform toolchains as needed:
  - Android: Android SDK/NDK, Java, Gradle via Flutter.
  - iOS/macOS: Xcode (ensure iPhoneOS platform runtime is installed), CocoaPods.
  - Windows/Linux: respective build toolchains.
- Node.js 18+ for data import scripts.

## Setup
- Install dependencies: `make deps`
- Static analysis and formatting: `make lint`

## Development
- Web (local dev server): `make dev-web WEB_PORT=5500`
- Chrome device: `make dev-chrome`
- macOS device: `make macos`
- Android build (copies APK to `/tmp/`): `make build-android`

### AI service URL
- The app reads a default backend AI service URL from `AI_SERVICE_URL` at build time and stores the value in preferences:
  - Default: `http://localhost:5600/`
  - Override at build/run: `--dart-define=AI_SERVICE_URL=https://your-backend.example.com/`
- The URL can be edited at runtime in Settings → App Settings → AI Service URL.

### AI Coach (Snowflake) behavior
- Backend endpoint: `POST /snowflake/refine`
- Returns coaching JSON with `status`, `critique`, `question`, and `suggestions`. When `status = "refined"`, it includes `refined_summary` and the app applies it to the Summary field automatically.
- Chat history is included in responses and rendered in the Coach panel; history is stored per novel.

## Tests
- Run tests with coverage summary: `make test`

### Router Coverage
- `test/routing/app_router_coverage_test.dart` provides comprehensive coverage for the app router.
- It validates navigation to over 20 routes including:
  - Auth screens (`/signup`, `/forgot-password`, etc.)
  - Simple screens (`/about`, `/my-novels`, etc.)
  - List screens (`/prompts`, `/patterns`, etc.)
  - Admin screens (`/admin/users`, `/admin/logs`)
  - Nested novel routes (`/novel/:id/summary`, `/novel/:id/characters`, etc.)
- These tests use `Fake` repositories and services to isolate routing logic from backend dependencies.

### Attach token to backend requests
- Obtain the access token from the current session:
  - `final token = ref.watch(sessionProvider);`
- Send it in the `Authorization` header (`Bearer` scheme) when calling the backend:

```dart

import 'package:http/http.dart' as http;

Future<http.Response> callBackend(Uri url) async {
  final token = ref.watch(sessionProvider);
  final headers = {
    if (token != null) 'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };
  return http.get(url, headers: headers);
}
```

- The app attaches this token automatically for AI calls and health checks; if a session exists but no token is present, it refreshes the session before retrying.
- The backend verifies this token via the auth service (`/auth/verify`). Requests without a token or with an invalid token receive `401 Unauthorized`. Premium-only routes return `403 Forbidden` for non-premium users.

### Gated endpoints
- `POST /agents/qa` requires authentication.
- `POST /agents/respond` requires authentication and a premium plan.

### Health polling
- The app polls `/health` adaptively:
  - Healthy → next check after 8 minutes
  - Unhealthy → next check after 2 minutes
  - Implementation: `lib/features/ai_chat/state/ai_chat_providers.dart`.

## Build Targets
- Web (release): `make build-web`
- Serve built web: `make serve-web-build WEB_PORT=8080`
- Android (APK release): `make build-android`
  - Automatically runs a plugin patch to ensure `isar_flutter_libs` compiles with SDK 36.
- Android (AAB for Play Console): `flutter build appbundle --release`
- Android (APK direct install): `flutter build apk --release`
- iOS (Xcode project, no codesign): `make build-ios`
- iOS (IPA):
  - Signed: `make build-ipa`
  - No codesign: `make build-ipa-nocodesign`
- Desktop:
  - macOS: `make build-macos`
  - Windows: `make build-windows`
  - Linux: `make build-linux`

## Platform Notes
- Android
  - The project patches `isar_flutter_libs` Gradle (`scripts/patch_isar.js`) to set `compileSdkVersion 36` and fix resource linking errors (e.g., `android:attr/lStar`).
  - If you run `flutter pub upgrade` and the plugin cache changes, the Makefile pre-step re-applies the patch before Android builds.
  - Package name/namespace: update `android/app/build.gradle.kts` (`namespace`) and `AndroidManifest.xml` before publishing. Current namespace: `com.huangjien.writer`.
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
- iOS platform not installed
  - Install the iOS platform runtime in Xcode as noted above.

- Windows plugin CMake parse error (`flutter_tts`)
  - Some versions of `flutter_tts` include CMake script constructs that break generation on certain runners.
  - CI removes `flutter_tts` from the Windows plugin list before building to ensure successful generation. If you need TTS on Windows locally, pin a compatible plugin version or exclude it for Windows.

## GCP Deployment

The Writer service can be deployed to Google Cloud Platform using the provided Makefile targets.

### Prerequisites

1. **Google Cloud SDK** installed and configured
2. **Docker** installed and running
3. **Authentication**:
   ```bash
   gcloud auth login
   gcloud auth configure-docker europe-west1-docker.pkg.dev
   ```

### GCP Configuration

The following variables can be set in your environment or use defaults:

- `PROJECT_ID` - GCP Project ID (default: inferred from gcloud)
- `RUN_REGION` - Cloud Run region (default: europe-west1)
- `REPO_NAME` - Artifact Registry repository name (default: writer)
- `SERVICE_NAME` - Cloud Run service name (default: writer-web)

### Deployment Commands

```bash
# Complete deployment (recommended)
make gcp-deploy-full

# Individual steps
make docker-setup-gcp    # Enable required APIs
make docker-create-repo   # Create Artifact Registry repo
make docker-build-gar     # Build & push Docker image
make docker-deploy-gcp    # Deploy to Cloud Run

# Management
make gcp-status           # Check deployment status
make gcp-delete-deployment # Delete service and repo
```

### Deployed Services

- **Writer Web**: https://writer-web-1026073243556.europe-west1.run.app
- **Backend API**: https://authorconsole-api-md5e22izxa-ew.a.run.app

### Environment Variables

The deployment automatically configures these secrets from Secret Manager:
- `OPENAI_API_KEY` - OpenAI API key
- `SUPABASE_SERVICE_ROLE_KEY` - Supabase service role key (backend only)

### Architecture Notes

- Docker images are built for `linux/amd64` platform to ensure Cloud Run compatibility
- Uses Artifact Registry for container storage
- Cloud Run provides serverless hosting with automatic scaling
- HTTPS endpoints with custom domains can be configured in GCP Console

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

## Security
- Never store or ship secrets in the app or in public repos. Use them only server-side or in secure CI contexts.

## Notes
- TTS locale mapping is covered by tests (`test/tts_locale_mapping_test.dart`). The task “Map app language preference to TTS language code” is tracked in `tasks.md` and can be extended if new locales are added.
