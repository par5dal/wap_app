plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Firebase Google Services
}

import java.util.Properties
import java.io.FileInputStream

// Cargar propiedades del keystore
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

// Cargar .env para obtener API_BASE_URL y derivar el host del callback
val envFile = rootProject.file("../.env")
val envProperties = Properties()
if (envFile.exists()) {
    envFile.readLines()
        .filter { it.isNotBlank() && !it.startsWith("#") && it.contains("=") }
        .forEach { line ->
            val (key, value) = line.split("=", limit = 2)
            envProperties[key.trim()] = value.trim()
        }
}
// Extraer solo el host de API_BASE_URL (ej: "api.whataplan.net" o "192.168.0.230")
// Elimina el scheme (http:// o https://) y el path/puerto que pueda haber
val apiBaseUrl = envProperties.getProperty("API_BASE_URL", "https://api.whataplan.net")
val apiCallbackHost = apiBaseUrl
    .removePrefix("https://")
    .removePrefix("http://")
    .split("/").first()   // quita paths
    .split(":").first()   // quita puerto

android {
    namespace = "com.jovelupe.wap"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.jovelupe.wap"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Inyectar host del API en el AndroidManifest para los App Links
        manifestPlaceholders["apiCallbackHost"] = apiCallbackHost
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            // Habilitar ProGuard/R8 para ofuscación y optimización
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
