## Makefile for Writer (Flutter)
## Usage examples:
##   make help
##   make dev-web WEB_PORT=5500
##   make deps
##   make test
##   make analyze
##   make format
##   make build-web
##   make serve-web-build WEB_PORT=8080

FLUTTER := flutter
SHELL := /usr/bin/env bash

# Optional configuration passed via make variables
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
DF_ARGS := $(strip $(if $(AI_SERVICE_URL),--dart-define AI_SERVICE_URL=$(AI_SERVICE_URL)) \
                 $(if $(DEFAULT_AGENT_RESPOND_MODEL),--dart-define DEFAULT_AGENT_RESPOND_MODEL=$(DEFAULT_AGENT_RESPOND_MODEL)) \
                 $(if $(DEFAULT_AGENT_QA_MODEL),--dart-define DEFAULT_AGENT_QA_MODEL=$(DEFAULT_AGENT_QA_MODEL)) \
                 $(if $(DEFAULT_AGENT_EMBEDDING_MODEL),--dart-define DEFAULT_AGENT_EMBEDDING_MODEL=$(DEFAULT_AGENT_EMBEDDING_MODEL)) \
                 $(if $(DEFAULT_AGENT_RESPOND_TEMPERATURE),--dart-define DEFAULT_AGENT_RESPOND_TEMPERATURE=$(DEFAULT_AGENT_RESPOND_TEMPERATURE)) \
                 $(if $(DEFAULT_AGENT_QA_TEMPERATURE),--dart-define DEFAULT_AGENT_QA_TEMPERATURE=$(DEFAULT_AGENT_QA_TEMPERATURE)) \
                 $(if $(DEFAULT_AGENT_EMBEDDING_TEMPERATURE),--dart-define DEFAULT_AGENT_EMBEDDING_TEMPERATURE=$(DEFAULT_AGENT_EMBEDDING_TEMPERATURE)))
# GCP Configuration (can be overridden via environment or command line)
PROJECT_ID ?= static-223923
RUN_REGION ?= europe-west1
IMAGE_URI ?= $(RUN_REGION)-docker.pkg.dev/$(PROJECT_ID)/authorconsole/writer-web:latest
IMAGE ?= writer-web:latest
AI_SERVICE_URL ?= https://ai.huangjien.com/

.PHONY: help dev-web dev-chrome macos deps test test-expanded analyze lint clean build-web serve-web-build env-print \
        build-macos build-android build-ios build-ios-signed build-ios-unsigned build-ios-app build-windows build-linux \
        build-ipa build-ipa-nocodesign install-ios install-ios-ipa install-ios-dev list-ios-devices install-hooks icons \
        docker-build-web docker-push-web docker-setup-gcp docker-create-repo docker-build-gar docker-deploy-gcp gcp-deploy-full \
        gcp-delete-deployment gcp-status ci

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
	@echo "  lint               - Run static analysis (alias of analyze) and format"
	@echo "  clean              - Clean Flutter build outputs"
	@echo "  build-web          - Build Flutter web app (release)"
	@echo "  build-macos        - Build macOS release app"
	@echo "  build-ios          - Build signed iOS IPA for device install"
	@echo "  build-ios-signed   - Build signed iOS IPA (requires signing)"
	@echo "  build-ios-unsigned - Build iOS IPA without codesign (export-only)"
	@echo "  build-ios-app      - Build iOS app bundle (no codesign)"
	@echo "  build-ipa          - Build iOS IPA (requires signing)"
	@echo "  build-ipa-nocodesign - Build iOS IPA without codesign (export-only)"
	@echo "  install-ios        - Install latest IPA onto a connected iPhone"
	@echo "  install-ios-ipa    - Install latest signed IPA onto a connected iPhone"
	@echo "  install-ios-dev    - Auto-sign Debug .app and install (DEV_TEAM/BUNDLE_ID optional)"
	@echo "  list-ios-devices   - List physical iOS devices (name, UDID, transport)"
	@echo "  build-android      - Build Android APK release"
	@echo "  build-windows      - Build Windows release app"
	@echo "  build-linux        - Build Linux release app"
	@echo "  serve-web-build    - Serve built web assets locally (requires python3)"
	@echo "  env-print          - Print env passed to dart-define"
	@echo "  install-hooks      - Configure git to use .githooks/ as hooks path"
	@echo "  publish-release    - Publish release to GitHub (defaults to version in package.json)"
	@echo "  ci                 - Mirror Writer CI locally (deps, icons, lint, tests)"
	@echo "  docker-build-gar   - Build and push Docker image to Google Artifact Registry"
	@echo "  docker-deploy-gcp  - Deploy to Google Cloud Run using Artifact Registry image"
	@echo "  gcp-deploy-full    - Complete GCP deployment: build, push, and deploy"

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
	./flutter_test_filtered.sh --timeout=30s

test:
	@START=$$(date +%s); \
	TIMESTAMP=$$(date +"%Y%m%d_%H%M%S"); \
	LOG_FILE="/tmp/writer_test_$$TIMESTAMP.log"; \
	echo "Running Flutter tests with filtered output ... (log saved to $$LOG_FILE)"; \
	echo@echo "Note: Skipping known flaky UI tests (ai_service_url_dialog_responsive_test.dart, settings_reduce_motion_toggle_test.dart)"; \
	set -o pipefail; \
	for test_file in test/dialogs/ai_service_url_dialog_responsive_test.dart test/settings_reduce_motion_toggle_test.dart; do \
		if [ -f "$$test_file" ]; then \
			mv "$$test_file" "$$test_file.skip"; \
		fi; \
	done; \
	./flutter_test_filtered.sh --coverage --timeout=30s 2>&1 | tee $$LOG_FILE; \
	for test_file in test/dialogs/ai_service_url_dialog_responsive_test.dart test/settings_reduce_motion_toggle_test.dart; do \
		if [ -f "$$test_file.skip" ]; then \
			mv "$$test_file.skip" "$$test_file"; \
		fi; \
	done; \
	if [ -f coverage/lcov.info ]; then \
		awk -F, '/^DA:/ { total++; if ($$2 > 0) hit++ } END { printf("Coverage: %.2f%% (%d/%d lines)\n", (hit/total)*100, hit, total) }' coverage/lcov.info | tee -a $$LOG_FILE; \
		TOTAL_LIB_LINES=$$(find lib -name '*.dart' -print0 | xargs -0 wc -l | tail -n 1 | awk '{print $$1}'); \
		awk -F, -v tot=$$TOTAL_LIB_LINES '/^DA:/ { if ($$2 > 0) hit++ } END { printf("Full-lines coverage: %.2f%% (%d/%d lines)\n", (hit/tot)*100, hit, tot) }' coverage/lcov.info | tee -a $$LOG_FILE; \
		if command -v genhtml >/dev/null 2>&1; then \
			genhtml -o coverage/html coverage/lcov.info; \
			echo "HTML coverage: coverage/html/index.html" | tee -a $$LOG_FILE; \
		else \
			echo "genhtml not found; install lcov to generate HTML coverage." | tee -a $$LOG_FILE; \
		fi; \
	else \
		echo "Coverage file not found; ensure --coverage succeeded." | tee -a $$LOG_FILE; \
	fi; \
	END=$$(date +%s); \
	ELAPSED=$$((END-START)); \
	printf "make test duration: %dm %ds\n" $$((ELAPSED/60)) $$((ELAPSED%60)) | tee -a $$LOG_FILE; \
	echo "Test log saved to: $$LOG_FILE"; \
	cp $$LOG_FILE ../test.log; \
	echo "Test log copied to project root: ../test.log"; \
	echo "Checking per-file coverage (<70%)..." | tee -a ../test.log; \
	{ LOG_FILE=$$LOG_FILE bash -lc 'set -o pipefail; dart check_coverage.dart 2>&1 | tee -a "$$LOG_FILE"' || true; } 2>&1 | tee -a ../test.log; \
	{ LOG_FILE=$$LOG_FILE bash -lc 'set -o pipefail; dart check_target_coverage.dart 90 2>&1 | tee -a "$$LOG_FILE"' || true; } 2>&1 | tee -a ../test.log; \
	echo "" | tee -a ../test.log; \
	echo "========================================" | tee -a ../test.log; \
	echo "FAILED TESTS SUMMARY" | tee -a ../test.log; \
	echo "========================================" | tee -a ../test.log; \
	perl -pe 's/\r/\n/g' $$LOG_FILE > /tmp/test_log_clean.txt; \
	grep -nE '~[0-9]+ -[0-9]+: .*\.dart: .* \[E\]' /tmp/test_log_clean.txt > /tmp/failed_tests.txt; \
	if [ -s /tmp/failed_tests.txt ]; then \
		cat /tmp/failed_tests.txt | tee -a ../test.log; \
		echo "" | tee -a ../test.log; \
		while IFS= read -r FAILED_LINE; do \
			LINE_NUM=$$(echo "$$FAILED_LINE" | cut -d: -f1); \
			TEST_NAME=$$(echo "$$FAILED_LINE" | sed 's/.*\.dart: //; s/ \[E\].*//'); \
			echo "--- FAILED: $$TEST_NAME ---" | tee -a ../test.log; \
			sed -n "$$((LINE_NUM+1)),$$((LINE_NUM+20))p" /tmp/test_log_clean.txt | head -20 >> ../test.log; \
			echo "" >> ../test.log; \
		done < /tmp/failed_tests.txt; \
		rm /tmp/failed_tests.txt /tmp/test_log_clean.txt; \
	else \
		echo "No failed tests found!" | tee -a ../test.log; \
		rm /tmp/test_log_clean.txt; \
	fi; \
	echo "========================================" | tee -a ../test.log; \
	echo "END OF FAILED TESTS SUMMARY" | tee -a ../test.log; \
	echo "========================================" | tee -a ../test.log

test-integration:
	$(FLUTTER) test -d macos --dart-define=AI_SERVICE_URL=$(AI_SERVICE_URL) integration_test/app_test.dart

test-expanded:
	@TIMESTAMP=$$(date +"%Y%m%d_%H%M%S"); \
	LOG_FILE="/tmp/writer_test_expanded_$$TIMESTAMP.log"; \
	echo "Running Flutter tests with expanded reporter and filtered output... (log saved to $$LOG_FILE)"; \
	set -o pipefail; \
	./flutter_test_filtered.sh $(DF_ARGS) --coverage -r expanded --timeout=30s 2>&1 | tee $$LOG_FILE; \
	if [ -f coverage/lcov.info ]; then \
		awk -F, '/^DA:/ { total++; if ($$2 > 0) hit++ } END { printf("Coverage: %.2f%% (%d/%d lines)\n", (hit/total)*100, hit, total) }' coverage/lcov.info | tee -a $$LOG_FILE; \
		TOTAL_LIB_LINES=$$(find lib -name '*.dart' -print0 | xargs -0 wc -l | tail -n 1 | awk '{print $$1}'); \
		awk -F, -v tot=$$TOTAL_LIB_LINES '/^DA:/ { if ($$2 > 0) hit++ } END { printf("Full-lines coverage: %.2f%% (%d/%d lines)\n", (hit/tot)*100, hit, tot) }' coverage/lcov.info | tee -a $$LOG_FILE; \
		if command -v genhtml >/dev/null 2>&1; then \
			genhtml -o coverage/html coverage/lcov.info; \
			echo "HTML coverage: coverage/html/index.html" | tee -a $$LOG_FILE; \
		else \
			echo "genhtml not found; install lcov to generate HTML coverage." | tee -a $$LOG_FILE; \
		fi; \
	else \
		echo "Coverage file not found; ensure --coverage succeeded." | tee -a $$LOG_FILE; \
	fi; \
	echo "Test log saved to: $$LOG_FILE"

analyze:
	dart analyze

lint:
	@echo "Running formatter..."
	dart format lib test
	@echo "Running analyzer..."
	dart analyze

clean:
	$(FLUTTER) clean

build-web:
	$(FLUTTER) build web $(DF_ARGS)

docker-build-web:
	docker build -t $(IMAGE) .

docker-push-web:
	docker push $(IMAGE)

build-macos:
	$(FLUTTER) build macos --release $(DF_ARGS)
	@if [ -d "/Applications" ] && [ -z "$$CI" ]; then \
		echo "Copying to /Applications..."; \
		cp -R "build/macos/Build/Products/Release/writer.app" "/Applications/" || echo "Failed to copy app"; \
	fi

build-ios:
	$(MAKE) build-ipa

build-ios-signed:
	$(MAKE) build-ipa

build-ios-unsigned:
	$(MAKE) build-ipa-nocodesign

build-ios-app:
	$(FLUTTER) build ios --release --no-codesign $(DF_ARGS)

build-ipa:
	$(FLUTTER) build ipa --release $(DF_ARGS)

build-ipa-nocodesign:
	$(FLUTTER) build ipa --release --no-codesign $(DF_ARGS)
	@set -euo pipefail; \
	OUT_DIR="build/ios/ipa"; \
	mkdir -p build/ios/ipa; \
	EXISTING_IPA=$$(ls -t build/ios/ipa/*.ipa 2>/dev/null | head -n 1 || true); \
	if [ -n "$$EXISTING_IPA" ]; then \
		echo "IPA already present: $$EXISTING_IPA"; \
		exit 0; \
	fi; \
	ARCHIVE_PATH="build/ios/archive/Runner.xcarchive"; \
	APP_PATH="$$ARCHIVE_PATH/Products/Applications/Runner.app"; \
	if [ ! -d "$$APP_PATH" ]; then \
		APP_PATH=$$(ls -td build/ios/iphoneos/*.app 2>/dev/null | head -n 1 || true); \
	fi; \
	if [ -z "$$APP_PATH" ] || [ ! -d "$$APP_PATH" ]; then \
		echo "ERROR: Could not find .app to package into IPA."; \
		exit 1; \
	fi; \
	STAGE_DIR=$$(mktemp -d -t writer_ipa_stage); \
	mkdir -p "$$STAGE_DIR/Payload"; \
	cp -R "$$APP_PATH" "$$STAGE_DIR/Payload/"; \
	PROJ_DIR=$$(pwd -P); \
	IPA_OUT="$$PROJ_DIR/build/ios/ipa/writer-unsigned.ipa"; \
	cd "$$STAGE_DIR" && zip -qr "$$IPA_OUT" Payload; \
	if [ ! -f "$$IPA_OUT" ]; then \
		echo "ERROR: Failed to create IPA archive"; \
		exit 1; \
	fi; \
	rm -rf "$$STAGE_DIR"; \
	echo "Unsigned IPA created at $$IPA_OUT"

install-ios-ipa:
	$(MAKE) install-ios

install-ios:
	@set -euo pipefail; \
	IPA_PATH="$${IPA_PATH:-}"; \
	if [ -z "$$IPA_PATH" ]; then \
		IPA_PATH=$$(ls -t build/ios/ipa/*.ipa 2>/dev/null | head -n 1 || true); \
	fi; \
	if [ -z "$$IPA_PATH" ] || [ ! -f "$$IPA_PATH" ]; then \
		echo "No IPA found. Building one first..."; \
		$(MAKE) build-ipa; \
		IPA_PATH=$$(ls -t build/ios/ipa/*.ipa 2>/dev/null | head -n 1 || true); \
	fi; \
	if [ -z "$$IPA_PATH" ] || [ ! -f "$$IPA_PATH" ]; then \
		echo "ERROR: IPA not found under build/ios/ipa/*.ipa"; \
		exit 1; \
	fi; \
	if ! command -v xcrun >/dev/null 2>&1; then \
		echo "ERROR: xcrun not found. Install Xcode Command Line Tools."; \
		exit 1; \
	fi; \
	if ! xcrun devicectl --help >/dev/null 2>&1; then \
		echo "ERROR: devicectl not available. Update Xcode to a version that includes CoreDevice devicectl."; \
		exit 1; \
	fi; \
	if ! command -v unzip >/dev/null 2>&1; then \
		echo "ERROR: unzip not found."; \
		exit 1; \
	fi; \
	DEVICE="$${DEVICE:-}"; \
	if [ -z "$$DEVICE" ]; then \
		DEVICE=$$(xcrun xctrace list devices 2>/dev/null \
			| grep -E 'iPhone|iPad|iPod|iOS' \
			| grep -vi simulator \
			| sed -E -n 's/.*\\(([0-9A-Fa-f-]{25,})\\).*/\\1/p' \
			| head -n 1 || true); \
		if [ -z "$$DEVICE" ]; then \
			TMP_JSON=$$(mktemp -t writer_devices); \
			xcrun devicectl list devices --timeout 15 --json-output "$$TMP_JSON" >/dev/null || true; \
			DEVICE=$$(JSON_FILE="$$TMP_JSON" python3 -c 'import os,json; p=os.environ.get("JSON_FILE") or ""; ud="";\
try:\
 d=json.load(open(p));\
 for dev in (d.get("result") or {}).get("devices") or []:\
  hw=dev.get("hardwareProperties") or {};\
  if (hw.get("platform") or "").lower()!="ios":\
   continue;\
  u=hw.get("udid");\
  if u: ud=u; break;\
except Exception:\
 pass;\
print(ud)' 2>/dev/null); \
			rm -f "$$TMP_JSON"; \
		fi; \
	fi; \
	if [ -z "$$DEVICE" ]; then \
		echo "ERROR: No connected iOS device found."; \
		echo "Tip: plug in your iPhone (USB), unlock it, and tap Trust on the prompt."; \
		exit 1; \
	fi; \
	echo "IPA: $$IPA_PATH"; \
	echo "Device: $$DEVICE"; \
	TMP_DIR=$$(mktemp -d /tmp/writer_ipa.XXXX); \
	echo "Extracting IPA..."; \
	unzip -q "$$IPA_PATH" -d "$$TMP_DIR"; \
	APP_PATH=$$(find "$$TMP_DIR/Payload" -maxdepth 1 -name "*.app" -print | head -n 1 || true); \
	if [ -z "$$APP_PATH" ] || [ ! -d "$$APP_PATH" ]; then \
		echo "ERROR: Could not locate .app inside IPA."; \
		rm -rf "$$TMP_DIR"; \
		exit 1; \
	fi; \
	echo "Installing app: $$(basename "$$APP_PATH")"; \
	echo "Progress:"; \
	xcrun devicectl device install app --device "$$DEVICE" "$$APP_PATH" --verbose --timeout 600; \
	rm -rf "$$TMP_DIR"; \
	echo "Install complete."

list-ios-devices:
	@set -euo pipefail; \
	echo "== xctrace devices =="; \
	xcrun xctrace list devices || true; \
	TMP_JSON=$$(mktemp -t writer_devices); \
	xcrun devicectl list devices --timeout 15 --json-output "$$TMP_JSON" >/dev/null || true; \
	echo "== devicectl devices (iOS only) =="; \
	python3 - "$$TMP_JSON" << 'PY' || true \
import json, sys \
p = sys.argv[1] \
try: \
    d = json.load(open(p)) \
    devs = (d.get('result') or {}).get('devices') or [] \
    for dev in devs: \
        hw = dev.get('hardwareProperties') or {} \
        conn = dev.get('connectionProperties') or {} \
        devp = dev.get('deviceProperties') or {} \
        if (hw.get('platform') or '').lower() != 'ios': \
            continue \
        name = devp.get('name') or 'Unknown' \
        udid = hw.get('udid') or '?' \
        transport = conn.get('transportType') or '?' \
        boot = devp.get('bootState') or '?' \
        pairing = conn.get('pairingState') or '?' \
        print(f"{name} | {udid} | {transport} | {boot} | {pairing}") \
except Exception: \
    pass \
PY \
	; \
	rm -f "$$TMP_JSON"
install-ios-dev:
	@set -euo pipefail; \
	if ! command -v xcodebuild >/dev/null 2>&1; then \
		echo "ERROR: xcodebuild not found. Install Xcode."; \
		exit 1; \
	fi; \
	if ! xcrun devicectl --help >/dev/null 2>&1; then \
		echo "ERROR: devicectl not available. Update Xcode to a version that includes CoreDevice devicectl."; \
		exit 1; \
	fi; \
	if [ -n "$${VERBOSE:-}" ]; then \
		echo "[VERBOSE] Attempting device auto-detection (xctrace first, then devicectl)"; \
		echo "[VERBOSE] xctrace devices output:"; \
		xcrun xctrace list devices || true; \
	fi; \
	DEVICE="$${DEVICE:-}"; \
	if [ -z "$$DEVICE" ]; then \
		DEVICE=$$(xcrun xctrace list devices 2>/dev/null \
			| grep -E 'iPhone|iPad|iPod|iOS' \
			| grep -vi simulator \
			| sed -E -n 's/.*\\(([0-9A-Fa-f-]{25,})\\).*/\\1/p' \
			| head -n 1 || true); \
		if [ -z "$$DEVICE" ]; then \
			TMP_JSON=$$(mktemp -t writer_devices); \
			xcrun devicectl list devices --timeout 15 --json-output "$$TMP_JSON" >/dev/null || true; \
			if [ -n "$${VERBOSE:-}" ] && [ -f "$$TMP_JSON" ]; then \
				echo "[VERBOSE] devicectl JSON saved to $$TMP_JSON"; \
			fi; \
			DEVICE=$$(JSON_FILE="$$TMP_JSON" python3 -c 'import os,json; p=os.environ.get("JSON_FILE") or ""; ud="";\
try:\
 d=json.load(open(p));\
 for dev in (d.get("result") or {}).get("devices") or []:\
  hw=dev.get("hardwareProperties") or {};\
  if (hw.get("platform") or "").lower()!="ios":\
   continue;\
  u=hw.get("udid");\
  if u: ud=u; break;\
except Exception:\
 pass;\
print(ud)' 2>/dev/null); \
			rm -f "$$TMP_JSON"; \
		fi; \
	fi; \
	if [ -n "$${VERBOSE:-}" ]; then \
		if [ -n "$$DEVICE" ]; then \
			echo "[VERBOSE] Chosen device UDID: $$DEVICE"; \
		else \
			echo "[VERBOSE] No device UDID detected"; \
		fi; \
	fi; \
	if [ -z "$$DEVICE" ]; then \
		echo "ERROR: No connected iOS device found."; \
		echo "Tip: plug in via USB, unlock, then in Finder click your device and Trust."; \
		echo "Also check: Settings → Privacy & Security → Developer Mode (enable, reboot)."; \
		exit 1; \
	fi; \
	echo "Building Debug .app with automatic signing..."; \
	if [ -z "$${DEV_TEAM:-}" ]; then \
		echo "Tip: pass DEV_TEAM=<TeamID> and optionally BUNDLE_ID=com.example.app to override signing."; \
	fi; \
	XCODE_OVERRIDES=""; \
	if [ -n "$${DEV_TEAM:-}" ]; then \
		XCODE_OVERRIDES="DEVELOPMENT_TEAM=$$DEV_TEAM CODE_SIGN_STYLE=Automatic CODE_SIGNING_ALLOWED=YES"; \
	fi; \
	if [ -n "$${BUNDLE_ID:-}" ]; then \
		XCODE_OVERRIDES="$$XCODE_OVERRIDES PRODUCT_BUNDLE_IDENTIFIER=$$BUNDLE_ID"; \
	fi; \
	xcodebuild \
		-workspace ios/Runner.xcworkspace \
		-scheme Runner \
		-configuration Debug \
		-destination "id=$$DEVICE" \
		-derivedDataPath build/xcode \
		-allowProvisioningUpdates \
		build $$XCODE_OVERRIDES | sed -e 's/^/  /'; \
	APP_PATH=$$(ls -td build/xcode/Build/Products/Debug-iphoneos/*.app 2>/dev/null | head -n 1 || true); \
	if [ -z "$$APP_PATH" ] || [ ! -d "$$APP_PATH" ]; then \
		echo "ERROR: Debug .app not found. Ensure a Team is set in Xcode and automatic signing is enabled."; \
		exit 1; \
	fi; \
	echo "Installing app: $$(basename "$$APP_PATH")"; \
	xcrun devicectl device install app --device "$$DEVICE" "$$APP_PATH" --verbose --timeout 600; \
	echo "Install complete."
build-android:
	$(FLUTTER) clean
	node scripts/patch_isar.js
	$(FLUTTER) build apk --release $(DF_ARGS)
	@echo "Copying APK to /tmp/..."
	cp build/app/outputs/flutter-apk/app-release.apk /tmp/

build-windows:
	node scripts/patch_flutter_tts_windows_cmake.js
	$(FLUTTER) build windows --release $(DF_ARGS)

build-linux:
	$(FLUTTER) build linux --release $(DF_ARGS)

serve-web-build:
	python3 -m http.server $(WEB_PORT) --directory build/web

env-print:
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

# GCP Deployment Targets
docker-setup-gcp:
	@echo "Setting up GCP environment..."
	@gcloud config set project "$(PROJECT_ID)" || { echo "Error: GCP not authenticated or project not found. Please run 'gcloud auth login' and 'gcloud config set project YOUR_PROJECT_ID'"; exit 1; }
	@echo "Enabling required APIs..."
	@gcloud services enable secretmanager.googleapis.com --project "$(PROJECT_ID)"
	@gcloud services enable artifactregistry.googleapis.com --project "$(PROJECT_ID)"

docker-create-repo:
	@echo "Setting up Artifact Registry repository..."
	@if ! gcloud artifacts repositories describe authorconsole --location="$(RUN_REGION)" --project "$(PROJECT_ID)" >/dev/null 2>&1; then \
		echo "Creating Artifact Registry repository..."; \
		gcloud artifacts repositories create authorconsole \
			--repository-format=docker \
			--location="$(RUN_REGION)" \
			--description="Docker repository for AuthorConsole" \
			--project "$(PROJECT_ID)"; \
	else \
		echo "Artifact Registry repository already exists"; \
	fi
	@echo "Configuring Docker authentication..."
	@gcloud auth configure-docker "$(RUN_REGION)-docker.pkg.dev"

docker-build-gar: docker-setup-gcp docker-create-repo
	@echo "Building Flutter web for Docker..."
	@$(MAKE) build-web
	@echo "Building Docker image: $(IMAGE_URI)"
	@docker build --platform linux/amd64 -t "$(IMAGE_URI)" .
	@echo "Pushing Docker image to Artifact Registry..."
	@docker push "$(IMAGE_URI)"
	@echo "Docker image successfully pushed to: $(IMAGE_URI)"

docker-deploy-gcp:
	@echo "Deploying to Google Cloud Run..."
	@gcloud run deploy writer-web \
		--quiet \
		--region "$(RUN_REGION)" \
		--update-secrets OPENAI_API_KEY=OPENAI_API_KEY:latest \
		--update-env-vars AI_SERVICE_URL="$(AI_SERVICE_URL)" \
		--image "$(IMAGE_URI)" \
		--platform managed \
		--port 8080 \
		--allow-unauthenticated \
		--project "$(PROJECT_ID)"
	@echo "Deployment completed successfully!"
	@echo "Service URL: $$(gcloud run services describe writer-web --region="$(RUN_REGION)" --format='value(status.url)' --project="$(PROJECT_ID)")"

gcp-deploy-full: docker-build-gar docker-deploy-gcp
	@echo "Complete GCP deployment finished!"

# GCP Management Targets
gcp-delete-deployment:
	@echo "Deleting Cloud Run service..."
	@gcloud run services delete writer-web --region="$(RUN_REGION)" --quiet --project "$(PROJECT_ID)" || echo "Service does not exist"
	@echo "Deleting Docker image from Artifact Registry..."
	@gcloud artifacts docker images delete "$(IMAGE_URI)" --delete-tags --quiet --project "$(PROJECT_ID)" || echo "Image does not exist"

gcp-status:
	@echo "=== GCP Deployment Status ==="
	@echo "Project: $(PROJECT_ID)"
	@echo "Region: $(RUN_REGION)"
	@echo "Image URI: $(IMAGE_URI)"
	@echo ""
	@echo "=== Cloud Run Service ==="
	@gcloud run services describe writer-web --region="$(RUN_REGION)" --format='table(name,status.url,status.latestReadyRevisionName)' --project="$(PROJECT_ID)" || echo "Service not found"
	@echo ""
	@echo "=== Artifact Registry Image ==="
	@gcloud artifacts docker images list "$(RUN_REGION)-docker.pkg.dev/$(PROJECT_ID)/authorconsole/writer-web" --format='table(version,createTime,imageSize,updateTime)' --project="$(PROJECT_ID)" || echo "Image not found"
