plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Flutter plugin
    id("com.google.gms.google-services") // Google services plugin
}

android {
    namespace = "com.example.smart_study_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"  // Set the NDK version here

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.smart_study_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// Break the circular dependency
tasks.whenTaskAdded { task ->
    if (task.name == "mergeDebugShaders") {
        task.mustRunAfter(":app:compileDebugShaders")
    }
}
