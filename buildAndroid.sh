# Clean any existing prebuild artifacts
rm -rf android ios

# Install dependencies to ensure expo-modules-core is available
pnpm install --frozen-lockfile

# Run prebuild with clean slate
pnpm exec expo prebuild --clean

# Build the Android APK
cd android && ./gradlew assembleRelease && cd ..

# Verify and move the APK
ls -al android/app/build/outputs/apk/release/app-release.apk
mv android/app/build/outputs/apk/release/app-release.apk ~/temp/writer.apk