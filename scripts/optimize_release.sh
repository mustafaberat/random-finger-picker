#!/bin/bash

# Ensure we're in the project root
cd "$(dirname "$0")/.."

echo "🔍 Starting app size optimization process..."

# Clean the project
echo "🧹 Cleaning project..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Enable build optimizations in gradle
echo "⚙️ Configuring Android build optimizations..."
cat << EOF > android/app/build.gradle
def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

def flutterRoot = localProperties.getProperty('flutter.sdk')
if (flutterRoot == null) {
    throw new GradleException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.")
}

def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
if (flutterVersionCode == null) {
    flutterVersionCode = '1'
}

def flutterVersionName = localProperties.getProperty('flutter.versionName')
if (flutterVersionName == null) {
    flutterVersionName = '1.0'
}

apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply from: "\$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"

android {
    namespace "com.example.random_finger_picker"
    compileSdkVersion flutter.compileSdkVersion
    ndkVersion flutter.ndkVersion

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }

    defaultConfig {
        applicationId "com.example.random_finger_picker"
        minSdkVersion flutter.minSdkVersion
        targetSdkVersion flutter.targetSdkVersion
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }

    buildTypes {
        release {
            // Enables code shrinking, obfuscation, and optimization
            minifyEnabled true
            shrinkResources true
            
            // Uses custom Proguard rules
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
            
            // Enables resource optimization
            crunchPngs true
            
            // Enables split APKs by ABI
            ndk {
                abiFilters 'armeabi-v7a', 'arm64-v8a', 'x86_64'
            }
        }
    }
}

flutter {
    source '../..'
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
}
EOF

# Create ProGuard rules
echo "📝 Creating ProGuard rules..."
cat << EOF > android/app/proguard-rules.pro
# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.editing.** { *; }

# Keep your application classes
-keep class com.example.random_finger_picker.** { *; }

# Optimize
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification

# Remove logging
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
}
EOF

# Build optimized release versions
echo "🏗️ Building optimized release versions..."

# Android APK (split by ABI)
echo "📱 Building Android APK..."
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/debug-info

# Android App Bundle
echo "📦 Building Android App Bundle..."
flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info

# iOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Building iOS..."
    flutter build ios --release --no-codesign
fi

echo "✅ Build process completed!"
echo "📊 Check the build outputs in build/app/outputs/flutter-apk/ for Android APKs"
echo "📊 Check build/app/outputs/bundle/release/ for Android App Bundle"
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "📊 Check build/ios/iphoneos/ for iOS build"
fi 