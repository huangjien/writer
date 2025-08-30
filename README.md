# Writer

*"Listening is the beginning of wisdom."*

A powerful cross-platform text-to-speech application that transforms your GitHub repositories into an immersive audio reading experience. Writer seamlessly integrates with GitHub to fetch and read your content aloud with natural voice synthesis.

## 🚀 Recent Updates

### Version 2.0.29 Highlights
- **Enhanced Audio Controls**: Audio focus management, media session integration, and earphone button support
- **Enhanced Testing Suite**: Comprehensive test coverage with 70+ passing tests
- **Improved GitHub Integration**: Robust API handling and error management
- **Advanced Coverage Reporting**: Detailed HTML coverage reports and analysis
- **TypeScript Enhancements**: Full type safety with strict configuration
- **Test Infrastructure**: Modern Jest setup with React Native Testing Library
- **Audio Interruption Handling**: Seamless management of phone calls and other audio interruptions
- **Documentation**: Comprehensive test coverage analysis and action plans

## ✨ Features

### 📖 Smart Reading Experience
- **GitHub Integration**: Direct access to your repositories and markdown files
- **Intelligent Content Processing**: Automatic text extraction and formatting
- **Chapter Navigation**: Seamless browsing through your content structure
- **Progress Tracking**: Remember where you left off in each document

### 🎧 Advanced Text-to-Speech
- **Natural Voice Synthesis**: High-quality speech output using Expo Speech
- **Adjustable Playback Speed**: Customize reading pace to your preference
- **Background Audio**: Continue listening while using other apps
- **Audio Controls**: Play, pause, skip, and navigate with intuitive controls
- **Audio Focus Management**: Automatically pauses when other apps take over audio
- **Media Session Integration**: System-level media controls in notification panel and lock screen
- **Earphone Button Controls**: Previous/next/play/pause/stop using earphone buttons
- **Audio Interruption Handling**: Seamless handling of phone calls and other audio interruptions

### 🎨 Customizable Interface
- **Dark/Light Mode**: Automatic theme switching based on system preferences
- **Responsive Design**: Optimized for phones, tablets, and web
- **Custom Backgrounds**: Personalize your reading environment
- **Gesture Controls**: Swipe navigation and touch interactions

### 🔐 Security & Authentication
- **Biometric Authentication**: Face ID and fingerprint support
- **Secure Storage**: Encrypted local data persistence
- **GitHub Token Management**: Secure API access configuration

### 🌍 Multi-Platform Support
- **iOS**: Native iOS app with platform-specific optimizations
- **Android**: Full Android support with adaptive icons
- **Web**: Progressive web app capabilities
- **Cross-Platform Sync**: Consistent experience across devices

## 🛠 Technology Stack

### Frontend Framework
- **React Native 0.79.5**: Cross-platform mobile development
- **Expo 53**: Development platform and build tools
- **TypeScript**: Type-safe development
- **NativeWind**: Tailwind CSS for React Native

### Navigation & UI
- **Expo Router**: File-based routing system
- **React Navigation**: Drawer navigation and screen management
- **React Native Gesture Handler**: Touch and gesture interactions
- **React Native Reanimated**: Smooth animations

### Data & Storage
- **AsyncStorage**: Local data persistence
- **GitHub API (@octokit/rest)**: Repository and content access
- **React Hook Form**: Form state management
- **Axios**: HTTP client for API requests

### Audio & Media
- **Expo Speech**: Text-to-speech synthesis
- **Expo AV**: Audio session management and interruption handling
- **React Native Track Player**: Advanced audio playback with media session support
- **Audio Toolkit**: Enhanced audio focus management and earphone controls
- **Background Tasks**: Continue audio playback in background with proper session management

### Development Tools
- **Jest**: Testing framework with comprehensive test suite (70+ tests)
- **Testing Library**: React Native testing utilities
- **TypeScript**: Full type safety with strict configuration
- **Prettier**: Code formatting and style consistency
- **Husky**: Git hooks for code quality assurance
- **Coverage Reporting**: Detailed test coverage analysis and HTML reports

## 🚀 Getting Started

### Prerequisites

- **Node.js** (v22 or later)
- **pnpm** (recommended package manager)
- **Expo CLI** (installed globally)
- **Git** for version control

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/huangjien/writer.git
   cd writer
   ```

2. **Install dependencies:**
   ```bash
   pnpm install
   ```

3. **Start the development server:**
   ```bash
   pnpm start
   # or use the convenience script
   ./start.sh
   ```

4. **Run on your device:**
   - **Mobile**: Use Expo Go app to scan the QR code
   - **iOS Simulator**: Press `i` in the terminal
   - **Android Emulator**: Press `a` in the terminal
   - **Web**: Press `w` in the terminal

### Development Scripts

The project includes several convenience scripts:

```bash
# Start development server with cache reset
./start.sh

# Run tests
pnpm test

# Check dependencies
./check.sh

# Format code
./prettier.sh

# Run health checks
./doctor.sh
```

## 📖 Usage

### Initial Setup

1. **Launch the app** and you'll see the welcome screen with key features
2. **Navigate to Settings** (⚙️ icon) to configure your preferences:
   - **GitHub Integration**: Add your GitHub personal access token
   - **Repository Settings**: Configure default repository and branch
   - **Voice Settings**: Adjust speech rate, pitch, and voice selection
   - **Reading Preferences**: Set font size, theme, and background

### Reading Content

1. **Browse Content**: Tap "Browse" to access your GitHub repositories
2. **Select Files**: Choose markdown files or documents to read
3. **Start Reading**: Tap on any file to begin reading
4. **Audio Controls**: Use the play bar to:
   - ▶️ Play/Pause audio
   - ⏮️⏭️ Navigate between chapters
   - 🔄 Adjust playback speed
   - 📍 Track reading progress
5. **System-Level Controls**: Access media controls from:
   - 📱 Notification panel (Android/iOS)
   - 🔒 Lock screen media controls
   - 🎧 Earphone button controls (play/pause/next/previous)
   - 📞 Automatic pause during phone calls and audio interruptions

### Navigation

- **Drawer Menu**: Swipe from left or tap the menu icon (☰)
- **Gesture Controls**: Swipe left/right to navigate chapters
- **Touch Controls**: Tap to pause/resume, long-press for options

### Key Features in Action

- **Background Playback**: Audio continues when app is minimized
- **Progress Sync**: Your reading position is automatically saved
- **Offline Access**: Previously loaded content works without internet
- **Multi-language**: Supports content in multiple languages
- **Smart Audio Management**: Automatically handles audio focus and interruptions
- **Universal Media Controls**: Works with system media controls and earphone buttons
- **Seamless Integration**: Integrates with device audio session for optimal user experience

## 🔧 Configuration

### GitHub Integration

1. **Generate a Personal Access Token**:
   - Go to GitHub Settings → Developer settings → Personal access tokens
   - Create a token with `repo` scope for private repositories
   - Copy the token for use in the app

2. **Configure in App**:
   - Open Settings → GitHub Configuration
   - Paste your token and set default repository
   - Test connection to verify setup

### Voice Customization

- **Speech Rate**: 0.5x to 2.0x speed
- **Voice Selection**: Choose from available system voices
- **Language**: Automatic detection or manual selection

## 🏗 Building for Production

### Prerequisites for Building

- **Android**: Android Studio and SDK
- **iOS**: Xcode (macOS only)
- **EAS CLI**: For cloud builds

### Local Development Build

1. **Prebuild the app**:
   ```bash
   pnpm exec expo prebuild
   ```

2. **Build for Android**:
   ```bash
   ./buildAndroid.sh
   # or manually:
   cd android && ./gradlew assembleRelease
   ```

3. **Build for iOS** (macOS only):
   ```bash
   cd ios
   xcodebuild -workspace writer.xcworkspace -scheme writer -configuration Release
   ```

### Production Release

```bash
# Create a production release
pnpm run publishRelease
```

This will:
- Run all tests
- Build the app
- Generate release artifacts
- Update version numbers

## 🧪 Testing

The project includes a comprehensive testing suite with **70+ passing tests** and detailed coverage reporting:

```bash
# Run all tests
pnpm test

# Run tests in watch mode
pnpm run test:watch

# Generate coverage report with HTML output
pnpm run test:coverage

# View coverage report
open coverage/lcov-report/index.html
```

### Test Coverage Status
- **Overall Coverage**: 40.78% statement coverage with ongoing improvements
- **Utils Module**: 100% coverage (excellent)
- **Services Module**: 88.73% coverage (good)
- **Components**: 90.9% statement coverage
- **Enhanced Test Suite**: Comprehensive integration tests for core functionality

### Test Categories
- **Unit Tests**: Component and utility function testing
- **Integration Tests**: GitHub API and storage integration
- **Hook Tests**: Custom React hooks validation with proper context providers
- **Service Tests**: Background services and speech functionality
- **Enhanced Tests**: Advanced component interaction and state management testing

### Test Infrastructure
- **Jest Configuration**: TypeScript support with module path mapping
- **Testing Library**: React Native testing utilities for component testing
- **Coverage Reports**: HTML and JSON coverage reports with detailed analysis
- **Mock System**: Comprehensive mocking for external dependencies
- **Test Documentation**: Detailed coverage analysis in `TEST_COVERAGE_SUMMARY.md`

## 🤝 Contributing

We welcome contributions! Here's how to get started:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes** and add tests
4. **Run the test suite**: `pnpm test`
5. **Format your code**: `./prettier.sh`
6. **Commit your changes**: `git commit -m 'Add amazing feature'`
7. **Push to the branch**: `git push origin feature/amazing-feature`
8. **Open a Pull Request**

### Development Guidelines

- Follow the existing code style and conventions
- Add tests for new functionality
- Update documentation as needed
- Ensure all CI checks pass

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Expo Team**: For the excellent development platform and tools
- **React Native Community**: For the robust ecosystem and components
- **GitHub**: For providing the API that powers our content integration
- **Open Source Contributors**: For the amazing libraries that make this app possible
- **Beta Testers**: For their valuable feedback and bug reports

## 📊 Project Documentation

### Testing & Coverage
- **Test Coverage Summary**: `TEST_COVERAGE_SUMMARY.md` - Comprehensive analysis of test coverage
- **Test Fixes Action Plan**: `TEST_FIXES_ACTION_PLAN.md` - Detailed improvement roadmap
- **Coverage Reports**: `coverage/lcov-report/index.html` - Interactive HTML coverage report
- **Dependency Analysis**: `DEPENDENCY_ANALYSIS.md` - Project dependency overview

### Release Information
- **Release Notes**: `RELEASE.md` - Version history and changelog
- **Build Scripts**: Various automation scripts for development and deployment

## 📞 Support

If you encounter any issues or have questions:

- **Issues**: [GitHub Issues](https://github.com/huangjien/writer/issues)
- **Discussions**: [GitHub Discussions](https://github.com/huangjien/writer/discussions)
- **Email**: Contact the maintainer for urgent matters
- **Documentation**: Check the project documentation files for detailed information

---

**"Auditus est initium sapientiae"** - *Listening is the beginning of wisdom*

Made with ❤️ by [Jien Huang](https://github.com/huangjien)

