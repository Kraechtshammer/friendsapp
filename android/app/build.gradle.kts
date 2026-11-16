import java.util.Base64
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing key, see docs/03-dev-setup.md "Releases". android/key.properties and the keystore
// are git-ignored; GitHub Actions writes them from repository secrets (.github/workflows/release.yml).
val releaseKey = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}
val hasReleaseKey = releaseKey.getProperty("storeFile") != null

// Incoming contact (M7), a build flag: `flutter build/run --dart-define=KEPT_INCOMING=true`.
// Flutter passes the dart-defines as one property, comma-separated, each entry base64 "KEY=value".
// Without the flag the notification listener (src/incomingOn: Kotlin and its manifest <service>)
// is left out and src/incomingOff gives MainActivity a stub, because Play Protect blocks
// sideloaded APKs with a notification listener. The Dart side reads the same flag
// (lib/app/build_flags.dart).
val keptIncoming = (project.findProperty("dart-defines") as String?)
    ?.split(",")
    ?.filter { it.isNotBlank() }
    ?.map { String(Base64.getDecoder().decode(it)) }
    ?.contains("KEPT_INCOMING=true") == true

android {
    namespace = "de.gartenpa.kept"
    // 37: required by the plugins.
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Needed by flutter_local_notifications (scheduled notifications)
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Package name on the phone. Final: changing it makes a different app with empty storage.
        applicationId = "de.gartenpa.kept"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // The name under the icon; the debug build type overrides it.
        manifestPlaceholders["appLabel"] = "Kept."
    }

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                storeFile = rootProject.file(releaseKey.getProperty("storeFile"))
                storePassword = releaseKey.getProperty("storePassword")
                keyAlias = releaseKey.getProperty("keyAlias")
                keyPassword = releaseKey.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        debug {
            // A separate app on the phone (de.gartenpa.kept.debug, "Kept. debug"), so a debug
            // build can sit beside the release and never touches its data.
            applicationIdSuffix = ".debug"
            manifestPlaceholders["appLabel"] = "Kept. debug"
        }
        release {
            // The release key when android/key.properties exists, otherwise the debug key
            // (fine for local testing, but such an APK can't update one signed with the release key).
            signingConfig = signingConfigs.getByName(if (hasReleaseKey) "release" else "debug")
        }
    }

    sourceSets {
        getByName("main") {
            java.directories.add(if (keptIncoming) "src/incomingOn/kotlin" else "src/incomingOff/kotlin")
        }
    }
}

// The listener's <service> entry, only with the flag (see keptIncoming above).
androidComponents {
    onVariants { variant ->
        if (keptIncoming) {
            variant.sources.manifests.addStaticManifestFile("src/incomingOn/AndroidManifest.xml")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
