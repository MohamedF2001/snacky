plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
}

group = "com.github.qwert2603.motion_sensors"
version = "1.0"

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Compatible avec AGP 8.x et Flutter récent
        classpath("com.android.tools.build:gradle:8.1.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.8.22")
    }
}

android {
    namespace = "com.github.qwert2603.motion_sensors"
    compileSdk = 33

    defaultConfig {
        minSdk = 21
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }
}

repositories {
    google()
    mavenCentral()
}

dependencies {
    implementation("androidx.annotation:annotation:1.6.0")
}
