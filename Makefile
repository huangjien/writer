## Makefile for Writer (Flutter)
## Usage examples:
##   make help
##   make dev-web WEB_PORT=5500
##   make dev-web SUPABASE_URL=https://your.supabase.co SUPABASE_ANON_KEY=xyz
##   make dev-chrome SUPABASE_URL=... SUPABASE_ANON_KEY=...
##   make deps
##   make test
##   make analyze
##   make format
##   make build-web SUPABASE_URL=... SUPABASE_ANON_KEY=...
##   make serve-web-build WEB_PORT=8080

FLUTTER := flutter

# Optional configuration passed via make variables
# Example: make dev-web SUPABASE_URL=... SUPABASE_ANON_KEY=...
SUPABASE_URL ?=
SUPABASE_ANON_KEY ?=
AI_SERVICE_URL ?=
DEFAULT_AGENT_RESPOND_MODEL ?=
DEFAULT_AGENT_QA_MODEL ?=
DEFAULT_AGENT_EMBEDDING_MODEL ?=
DEFAULT_AGENT_RESPOND_TEMPERATURE ?=
DEFAULT_AGENT_QA_TEMPERATURE ?=
DEFAULT_AGENT_EMBEDDING_TEMPERATURE ?=
WEB_PORT ?= 5500

# Default TAG to version from package.json if not provided
PACKAGE_VERSION := $(shell node -p "require('./package.json').version" 2>/dev/null || echo "0.0.0")
TAG ?= v$(PACKAGE_VERSION)

# Construct dart-define args only when variables are provided
DF_ARGS := $(strip $(if $(SUPABASE_URL),--dart-define SUPABASE_URL=$(SUPABASE_URL)) \
                 $(if $(SUPABASE_ANON_KEY),--dart-define SUPABASE_ANON_KEY=$(SUPABASE_ANON_KEY)) \
                 $(if $(AI_SERVICE_URL),--dart-define AI_SERVICE_URL=$(AI_SERVICE_URL)) \
                 $(if $(DEFAULT_AGENT_RESPOND_MODEL),--dart-define DEFAULT_AGENT_RESPOND_MODEL=$(DEFAULT_AGENT_RESPOND_MODEL)) \
                 $(if $(DEFAULT_AGENT_QA_MODEL),--dart-define DEFAULT_AGENT_QA_MODEL=$(DEFAULT_AGENT_QA_MODEL)) \
                 $(if $(DEFAULT_AGENT_EMBEDDING_MODEL),--dart-define DEFAULT_AGENT_EMBEDDING_MODEL=$(DEFAULT_AGENT_EMBEDDING_MODEL)) \
                 $(if $(DEFAULT_AGENT_RESPOND_TEMPERATURE),--dart-define DEFAULT_AGENT_RESPOND_TEMPERATURE=$(DEFAULT_AGENT_RESPOND_TEMPERATURE)) \
                 $(if $(DEFAULT_AGENT_QA_TEMPERATURE),--dart-define DEFAULT_AGENT_QA_TEMPERATURE=$(DEFAULT_AGENT_QA_TEMPERATURE)) \
                 $(if $(DEFAULT_AGENT_EMBEDDING_TEMPERATURE),--dart-define DEFAULT_AGENT_EMBEDDING_TEMPERATURE=$(DEFAULT_AGENT_EMBEDDING_TEMPERATURE)))
IMAGE ?= writer-web:latest

.PHONY: help dev-web dev-chrome macos deps test test-expanded analyze lint format clean build-web serve-web-build env-print \
        build-macos build-android build-ios build-windows build-linux build-ipa build-ipa-nocodesign install-hooks icons \
        docker-build-web docker-push-web ci

help:
	@echo "Available targets:"
	@echo "  help               - Show this help"
	@echo "  dev-web            - Run development server on web-server (port $(WEB_PORT))"
	@echo "  dev-chrome         - Run development in Chrome device"
	@echo "  macos              - Run development on macOS device"
	@echo "  deps               - Install pub dependencies"
	@echo "  test               - Run unit/widget tests (with coverage summary)"
	@echo "  test-expanded      - Run tests with expanded reporter and coverage summary"
	@echo "  analyze            - Run static analysis (Dart)"
	@echo "  lint               - Run static analysis (alias of analyze)"
	@echo "  format             - Format source files"
	@echo "  clean              - Clean Flutter build outputs"
	@echo "  build-web          - Build Flutter web app (release)"
	@echo "  build-macos        - Build macOS release app"
	@echo "  build-ios          - Build iOS release (no codesign)"
	@echo "  build-ipa          - Build iOS IPA (requires signing)"
	@echo "  build-ipa-nocodesign - Build iOS IPA without codesign (export-only)"
	@echo "  build-android      - Build Android APK release"
	@echo "  build-windows      - Build Windows release app"
	@echo "  build-linux        - Build Linux release app"
	@echo "  serve-web-build    - Serve built web assets locally (requires python3)"
	@echo "  env-print          - Print Supabase env passed to dart-define"
	@echo "  install-hooks      - Configure git to use .githooks/ as hooks path"
	@echo "  publish-release    - Publish release to GitHub (defaults to version in package.json)"
	@echo "  ci                 - Mirror Writer CI locally (deps, icons, lint, tests)"

dev-web:
	$(FLUTTER) run -d web-server --web-port $(WEB_PORT) $(DF_ARGS)

dev-chrome:
	$(FLUTTER) run -d chrome $(DF_ARGS)

macos:
	$(FLUTTER) run -d macos $(DF_ARGS)

deps:
	$(FLUTTER) pub get

upgrade:
	$(FLUTTER) pub upgrade

icons:
	$(FLUTTER) pub get
	$(FLUTTER) pub run flutter_launcher_icons

ci:
	$(FLUTTER) pub get
	$(FLUTTER) pub run flutter_launcher_icons
	$(MAKE) lint
	$(FLUTTER) test --test-randomize-ordering-seed=random -j 1

test:
	@START=$$(date +%s); \
	$(FLUTTER) test --coverage --test-randomize-ordering-seed=random -j 1; \
	if [ -f coverage/lcov.info ]; then \
		awk -F, '/^DA:/ { total++; if ($$2 > 0) hit++ } END { printf("Coverage: %.2f%% (%d/%d lines)\n", (hit/total)*100, hit, total) }' coverage/lcov.info; \
		TOTAL_LIB_LINES=$$(find lib -name '*.dart' -print0 | xargs -0 wc -l | tail -n 1 | awk '{print $$1}'); \
		awk -F, -v tot=$$TOTAL_LIB_LINES '/^DA:/ { if ($$2 > 0) hit++ } END { printf("Full-lines coverage: %.2f%% (%d/%d lines)\n", (hit/tot)*100, hit, tot) }' coverage/lcov.info; \
		if command -v genhtml >/dev/null 2>&1; then \
			genhtml -o coverage/html coverage/lcov.info; \
			echo "HTML coverage: coverage/html/index.html"; \
		else \
			echo "genhtml not found; install lcov to generate HTML coverage."; \
		fi; \
	else \
		echo "Coverage file not found; ensure --coverage succeeded."; \
	fi; \
	echo "Checking per-file coverage (<85%)..."; \
	dart check_coverage.dart; \
	END=$$(date +%s); \
	ELAPSED=$$((END-START)); \
	printf "make test duration: %dm %ds\n" $$((ELAPSED/60)) $$((ELAPSED%60))

test-expanded:
	$(FLUTTER) test $(DF_ARGS) --coverage -r expanded --test-randomize-ordering-seed=random -j 1
	@if [ -f coverage/lcov.info ]; then \
		awk -F, '/^DA:/ { total++; if ($$2 > 0) hit++ } END { printf("Coverage: %.2f%% (%d/%d lines)\n", (hit/total)*100, hit, total) }' coverage/lcov.info; \
		TOTAL_LIB_LINES=$$(find lib -name '*.dart' -print0 | xargs -0 wc -l | tail -n 1 | awk '{print $$1}'); \
		awk -F, -v tot=$$TOTAL_LIB_LINES '/^DA:/ { if ($$2 > 0) hit++ } END { printf("Full-lines coverage: %.2f%% (%d/%d lines)\n", (hit/tot)*100, hit, tot) }' coverage/lcov.info; \
		if command -v genhtml >/dev/null 2>&1; then \
			genhtml -o coverage/html coverage/lcov.info; \
			echo "HTML coverage: coverage/html/index.html"; \
		else \
			echo "genhtml not found; install lcov to generate HTML coverage."; \
		fi; \
	else \
		echo "Coverage file not found; ensure --coverage succeeded."; \
	fi

analyze:
	dart analyze

lint:
	@echo "Running formatter check (no changes allowed)..."
	# Use output=show to avoid writing; suppress output to keep logs clean
	dart format --output show --set-exit-if-changed lib test >/dev/null
	@echo "Running analyzer with fatal infos..."
	dart analyze --fatal-infos

format:
	dart format lib test

clean:
	$(FLUTTER) clean

build-web:
	$(FLUTTER) build web $(DF_ARGS)

docker-build-web:
	docker build -t $(IMAGE) .

docker-push-web:
	docker push $(IMAGE)

## Release builds (pass SUPABASE_URL/SUPABASE_ANON_KEY if needed)
build-macos:
	$(FLUTTER) build macos --release $(DF_ARGS)

build-ios:
	# Builds without code signing for portability; configure signing in Xcode if needed.
	$(FLUTTER) build ios --release --no-codesign $(DF_ARGS)

build-ipa:
	$(FLUTTER) build ipa --release $(DF_ARGS)

build-ipa-nocodesign:
	$(FLUTTER) build ipa --release --no-codesign $(DF_ARGS)

build-android:
	$(FLUTTER) clean
	node scripts/patch_isar.js
	$(FLUTTER) build apk --release $(DF_ARGS)

build-windows:
	node scripts/patch_flutter_tts_windows_cmake.js
	$(FLUTTER) build windows --release $(DF_ARGS)

build-linux:
	$(FLUTTER) build linux --release $(DF_ARGS)

serve-web-build:
	python3 -m http.server $(WEB_PORT) --directory build/web

env-print:
	@echo "SUPABASE_URL=$(SUPABASE_URL)"
	@echo "SUPABASE_ANON_KEY=$(SUPABASE_ANON_KEY)"
	@echo "AI_SERVICE_URL=$(AI_SERVICE_URL)"
	@echo "DEFAULT_AGENT_RESPOND_MODEL=$(DEFAULT_AGENT_RESPOND_MODEL)"
	@echo "DEFAULT_AGENT_QA_MODEL=$(DEFAULT_AGENT_QA_MODEL)"
	@echo "DEFAULT_AGENT_EMBEDDING_MODEL=$(DEFAULT_AGENT_EMBEDDING_MODEL)"
	@echo "DEFAULT_AGENT_RESPOND_TEMPERATURE=$(DEFAULT_AGENT_RESPOND_TEMPERATURE)"
	@echo "DEFAULT_AGENT_QA_TEMPERATURE=$(DEFAULT_AGENT_QA_TEMPERATURE)"
	@echo "DEFAULT_AGENT_EMBEDDING_TEMPERATURE=$(DEFAULT_AGENT_EMBEDDING_TEMPERATURE)"
	@echo "DF_ARGS=$(DF_ARGS)"

install-hooks:
	git config core.hooksPath .githooks
	ROOT_DIR=$$(git rev-parse --show-toplevel); \
	chmod +x $$ROOT_DIR/.githooks/pre-commit || true

publish-release:
	@command -v gh >/dev/null 2>&1 || { echo >&2 "GitHub CLI (gh) is not installed. Aborting."; exit 1; }
	@echo "Creating GitHub release $(TAG)..."
	gh release create $(TAG) --generate-notes
	@echo "Processing build artifacts..."
	@# Upload macOS App
	@if [ -d "build/macos/Build/Products/Release" ]; then \
		APP_PATH=$$(find build/macos/Build/Products/Release -name "*.app" | head -n 1); \
		if [ -n "$$APP_PATH" ]; then \
			APP_NAME=$$(basename "$$APP_PATH"); \
			echo "Zipping $$APP_NAME..."; \
			cd build/macos/Build/Products/Release && \
			zip -r "$${APP_NAME%.*}-macos-$(TAG).zip" "$$APP_NAME" && \
			gh release upload $(TAG) "$${APP_NAME%.*}-macos-$(TAG).zip"; \
		fi \
	fi
	@# Upload Android APK
	@if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then \
		echo "Uploading Android APK..."; \
		cp build/app/outputs/flutter-apk/app-release.apk build/app/outputs/flutter-apk/writer-android-$(TAG).apk && \
		gh release upload $(TAG) build/app/outputs/flutter-apk/writer-android-$(TAG).apk; \
	fi
	@# Upload iOS IPA
	@if [ -f "build/ios/ipa/writer.ipa" ]; then \
		echo "Uploading iOS IPA..."; \
		cp build/ios/ipa/writer.ipa build/ios/ipa/writer-ios-$(TAG).ipa && \
		gh release upload $(TAG) build/ios/ipa/writer-ios-$(TAG).ipa; \
	fi
