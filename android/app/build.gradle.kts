plugins {
    id("com.android.application")
    // Align with plugin id declared in settings.gradle.kts
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.huangjien.writer"
    // Use Flutter-managed SDK versions for consistency and proper dependency resolution
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Application ID updated to match final namespace.
        applicationId = "com.huangjien.writer"
        // Align with Flutter’s configured SDK versions
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.media:media:1.7.0")
}

// Suppress obsolete Java compiler option warnings emitted by transitive builds
// Some plugin code or generated sources may still target source/target 8.
// This adds -Xlint:-options to all JavaCompile tasks in this module.
tasks.withType<JavaCompile>().configureEach {
    options.compilerArgs.add("-Xlint:-options")
}
