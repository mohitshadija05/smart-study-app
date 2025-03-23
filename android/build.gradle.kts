buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Add the Google services classpath in the buildscript block
        classpath("com.android.tools.build:gradle:7.2.1")  // Make sure the Android Gradle plugin version is correct
        classpath("com.google.gms:google-services:4.3.10")  // Google services classpath
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

subprojects {
    val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
    project.layout.buildDirectory.value(newBuildDir)
    project.evaluationDependsOn(":app")
}
