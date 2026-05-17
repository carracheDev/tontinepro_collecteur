// ── Résolution offline : mobile_scanner demande 8.13.0 qui n'est pas
// en cache, mais 8.13.1 l'est. On force tous les sous-projets à utiliser
// la version en cache pour éviter tout téléchargement réseau.
gradle.allprojects {
    buildscript {
        configurations.configureEach {
            resolutionStrategy {
                force("com.android.tools.build:gradle:8.13.1")
                force("com.android.tools.build:builder:8.13.1")
                force("com.android.tools.analytics-library:protos:31.13.1")
            }
        }
    }
}

pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.9.1" apply false
    id("com.android.library") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
    id("com.google.gms.google-services") version "4.4.2" apply false
}

include(":app")
