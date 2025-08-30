# GitHub Release Publisher

This document explains how to use the `publishRelease.sh` script to publish your Writer Android APK to GitHub releases.

## Prerequisites

1. **GitHub CLI**: Install the GitHub CLI tool
   ```bash
   brew install gh
   ```

2. **GitHub Personal Access Token**: Create a token with `repo` permissions
   - Go to GitHub Settings → Developer settings → Personal access tokens
   - Generate a new token with `repo` scope
   - Copy the token

3. **Built APK**: Ensure you have built the Android APK
   ```bash
   ./buildAndroid.sh
   ```

## Usage

### Basic Usage

1. Set your GitHub token:
   ```bash
   export GITHUB_TOKEN=your_github_token_here
   ```

2. Run the release script:
   ```bash
   ./publishRelease.sh
   ```

### Advanced Usage

You can customize the release by setting environment variables:

```bash
# Set custom repository owner (defaults to git config user.name)
export GITHUB_REPO_OWNER=your-username

# Set custom repository name (defaults to 'writer')
export GITHUB_REPO_NAME=your-repo-name

# Set custom release tag (defaults to timestamp)
export RELEASE_TAG=v1.0.0

# Run the script
./publishRelease.sh
```

## What the Script Does

1. **Validates Prerequisites**: Checks for APK file, GitHub token, and GitHub CLI
2. **Authenticates**: Logs into GitHub using your token
3. **Creates Release**: Creates a new GitHub release with auto-generated tag
4. **Uploads APK**: Attaches the `writer.apk` file to the release
5. **Provides URL**: Shows the direct link to your new release

## Example Output

```
🚀 GitHub Release Publisher
==============================
🔐 Authenticating with GitHub...
📋 Repository Info:
Owner: your-username
Repository: writer
Tag: v20240702-231500
APK: ~/temp/writer.apk

Do you want to proceed with the release? (y/N): y
📦 Creating GitHub release...
✅ Release created successfully
📤 Uploading APK to release...
✅ APK uploaded successfully
🎉 Release published!

Release URL: https://github.com/your-username/writer/releases/tag/v20240702-231500
✨ All done!
```

## Troubleshooting

- **APK not found**: Run `./buildAndroid.sh` first
- **GitHub token error**: Ensure `GITHUB_TOKEN` is set and has `repo` permissions
- **GitHub CLI not found**: Install with `brew install gh`
- **Authentication failed**: Check your token permissions and validity

## Test Coverage Report

The project now includes comprehensive test coverage reporting and enhanced testing capabilities.

### Coverage Report Location
- **HTML Report**: `coverage/lcov-report/index.html`
- **JSON Report**: `coverage/coverage-final.json`
- **Detailed Analysis**: `coverage/COVERAGE_REPORT.md`

### Current Coverage Status
- **Statements**: 40.78% (312/765)
- **Branches**: 28.9% (50/173)
- **Functions**: 33.33% (49/147)
- **Lines**: 39.94% (288/721)

### Enhanced Test Suite
A new enhanced test suite has been created for the read component:
- **File**: `src/__tests__/read.enhanced.test.tsx`
- **Tests**: 35 comprehensive test cases
- **Features**: Isolated mocks, robust error handling, multiple rendering scenarios

### Current Test Issues

#### Critical Test Failures (124 failing tests)
The test suite currently has significant issues that need to be addressed:

1. **useThemeConfig Hook Tests** (22 failures)
   - **Issue**: Hook returning `null` instead of expected object
   - **Root Cause**: Missing proper AsyncStorageProvider wrapper in tests
   - **Fix**: Update test setup to properly wrap hooks with required providers

2. **useAsyncStorage Tests** (Multiple failures)
   - **Issue**: Context not properly initialized in test environment
   - **Root Cause**: Mock setup conflicts and missing provider context
   - **Fix**: Isolate test mocks and ensure proper provider wrapping

3. **Module Resolution Errors**
   - **Issue**: Cannot locate `@/components/use-theme-config` module
   - **Root Cause**: Incorrect path mapping in Jest configuration
   - **Fix**: Update Jest moduleNameMapper configuration

4. **SpeechService Tests**
   - **Issue**: Mock functions not being called as expected
   - **Root Cause**: Incomplete mock setup for toast notifications
   - **Fix**: Properly mock all external dependencies

#### Test Infrastructure Issues

1. **Setup Files**
   - Some test files (setup.ts, test-utils.tsx) are being treated as test suites
   - **Fix**: Exclude setup files from test discovery

2. **Mock Conflicts**
   - Global mocks interfering with individual test requirements
   - **Fix**: Use isolated mocks per test file when needed

3. **TypeScript Configuration**
   - Path resolution issues in test environment
   - **Fix**: Align Jest configuration with TypeScript paths

### Running Tests with Coverage
```bash
# Run all tests with coverage (currently failing)
pnpm test -- --coverage --watchAll=false

# Run specific working test file
pnpm test -- src/__tests__/read.enhanced.test.tsx

# Run tests in watch mode
pnpm test
```

### Coverage by Module
- **Utils**: 100% coverage (excellent)
- **Services**: 88.73% coverage (good, but has test failures)
- **Components**: 90.9% coverage (good)
- **App**: 20.86% coverage (needs improvement)
- **Hooks**: 15.88% coverage (needs significant improvement, has test failures)

### Immediate Action Items

1. **Fix Test Infrastructure**
   - Update Jest configuration for proper module resolution
   - Fix AsyncStorageProvider wrapper issues
   - Resolve mock conflicts

2. **Fix Failing Tests**
   - useThemeConfig: Add proper provider wrapper
   - useAsyncStorage: Fix context initialization
   - SpeechService: Complete mock setup

3. **Improve Coverage**
   - Add tests for app components (read.tsx, index.tsx)
   - Test custom hooks comprehensively
   - Focus on branch coverage improvement

### Coverage Improvement Goals
- **Target Overall Coverage**: 80%+
- **Priority Areas**: Fix existing test failures first, then App module, Hooks module
- **Focus**: Branch coverage improvement (currently 28.9%)
- **Next Steps**: Stabilize test suite, then expand coverage

### Additional Documentation

- **Comprehensive Analysis**: `TEST_COVERAGE_SUMMARY.md` - Executive summary and strategic overview
- **Action Plan**: `TEST_FIXES_ACTION_PLAN.md` - Step-by-step instructions for fixing test failures
- **Detailed Coverage**: `coverage/COVERAGE_REPORT.md` - Module-by-module coverage analysis

### Key Insights

1. **Infrastructure Issues**: 124 failing tests primarily due to Jest configuration and mock setup problems
2. **Module Performance**: Utils (100%) and Services (88.73%) modules have excellent coverage
3. **Critical Gaps**: App (20.86%) and Hooks (15.88%) modules need significant testing improvement
4. **Working Example**: Enhanced test suite demonstrates comprehensive testing is achievable

### Success Metrics

**Short-term (1-2 weeks)**:
- Reduce failing tests from 124 to < 20
- Fix all infrastructure issues
- Achieve stable test suite execution

**Medium-term (3-4 weeks)**:
- Achieve 60%+ overall statement coverage
- Improve branch coverage to 50%+
- Complete app component and hook testing

**Long-term (1-2 months)**:
- Achieve 80%+ overall coverage
- Implement automated coverage gates
- Add integration test suite

## Dependency Analysis & Project Health

### Dependency Issues Resolution ✅

The project's **critical dependency conflicts** have been successfully resolved:

#### Fixed Expo SDK Package Conflicts
- **@expo/config-plugins**: ✅ Updated to compatible version
- **@expo/prebuild-config**: ✅ Updated to compatible version  
- **@expo/metro-config**: ✅ Updated to compatible version

#### Resolution Actions Completed
- **@expo/cli** updated to latest version
- Clean reinstall of all dependencies completed
- Development server now starts successfully

#### Current Status
- **Development Server**: ✅ Working properly
- **Build Stability**: ✅ Significantly improved
- **Test Infrastructure**: ✅ Ready for test fixes

### Actions Completed ✅

1. **Updated @expo/cli**: ✅ Successfully updated to latest version

2. **Clean install**: ✅ Completed dependency refresh

3. **Verification**: ✅ Development infrastructure working
   ```bash
   ./doctor.sh
   ```
   Result: Development server operational

### Documentation

- **Detailed Analysis**: `DEPENDENCY_ANALYSIS.md` - Complete dependency conflict analysis and solutions
- **Test Coverage**: `TEST_COVERAGE_SUMMARY.md` - Current test status and improvement plan
- **Action Plan**: `TEST_FIXES_ACTION_PLAN.md` - Step-by-step test fixes

### Current Priority Order

1. **✅ Completed**: Fix dependency conflicts - RESOLVED
2. **🟡 Current Focus**: Stabilize test infrastructure (124 failing tests remain)
3. **🟢 Next**: Improve test coverage after infrastructure fixes
4. **🔵 Future**: Enhance development workflow

**✅ Progress**: Dependency infrastructure resolved, now focusing on test suite stabilization.

## Security Notes

- Never commit your GitHub token to the repository
- Use environment variables or secure credential storage
- The token should have minimal required permissions (`repo` scope only)