import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing is read from android/key.properties (kept out of version
// control — see android/key.properties.example). Until that file exists, the
// release build falls back to debug signing so `flutter run --release` keeps
// working. Provide it before generating the Play upload artifact.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "dev.cairn"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Required by flutter_local_notifications (uses java.time desugaring).
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // Placeholder production applicationId — replace with a domain you own before Play release.
        applicationId = "dev.cairn"
        // minSdk 26 (Android 8.0): solid WorkManager behaviour + broad device coverage (PRD §3).
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = (keystoreProperties["storeFile"] as String?)?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Uses the real upload key once android/key.properties exists; until
            // then falls back to debug signing so local release runs still work.
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            // R8/obfuscation renames classes WorkManager + Room instantiate by
            // reflection (WorkDatabase, our ReconciliationWorker/BootReceiver),
            // which crashed the release build on startup. Disable shrinking for
            // now; re-enable with proper keep rules before a Play release.
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    // Native daily reconciliation worker (~04:05) + BOOT reschedule.
    implementation("androidx.work:work-runtime-ktx:2.9.1")
}
