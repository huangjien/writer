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
        build-macos build-android build-ios build-windows build-linux build-ipa build-ipa-nocodesign install-hooks icons \
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
	@echo "  build-ios          - Build iOS release (no codesign)"
	@echo "  build-ipa          - Build iOS IPA (requires signing)"
	@echo "  build-ipa-nocodesign - Build iOS IPA without codesign (export-only)"
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
	echo "Checking per-file coverage (<80%)..."; \
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
	@echo "Running formatter..."
	dart format lib test
	@echo "Running analyzer with fatal infos..."
	dart analyze --fatal-infos

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
