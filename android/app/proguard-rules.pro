# Flutter specific rules
-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}

# Keep Flutter app
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep your application classes that have native methods
-keepclasseswithmembers class com.arusoft.randomfingerpicker.** {
    native <methods>;
}

# Aggressive optimization
-optimizations !code/allocation/variable
-optimizationpasses 5
-allowaccessmodification
-dontpreverify

# Remove all debug logs
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
}

# Remove unused code
-dontwarn android.test.**
-dontwarn org.junit.**
-dontwarn android.support.test.**
-dontwarn org.jetbrains.annotations.**
-dontwarn kotlin.**

# Keep necessary classes for animations and UI
-keep class com.arusoft.randomfingerpicker.animations.** { *; }
-keep class com.arusoft.randomfingerpicker.screens.** { *; }

# Confetti package rules
-keep class com.arusoft.randomfingerpicker.confetti.** { *; }

# Additional optimizations
-repackageclasses ''
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Remove kotlin metadata
-dontwarn kotlin.**
-dontwarn org.jetbrains.annotations.**
-keep class kotlin.Metadata { *; }

# Remove android logging
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

# Play Core library
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
