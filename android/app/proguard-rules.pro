# Flutter/ProGuard rules for Guarden

# Keep Kotlin logging classes referenced by various libraries
-keep class ch.qos.logback.** { *; }
-keep class org.slf4j.** { *; }

# Keep tinylog classes
-keep class org.tinylog.** { *; }

# Keep Kotlin logging
-keep class io.github.oshai.kotlinlogging.** { *; }

# Workmanager
-keep class dev.fluttercommunity.workmanager.** { *; }

# Google APIs
-keep class com.google.api.** { *; }
-keep class com.google.apis.** { *; }

# Google Sign-In
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.games.** { *; }
-keep class com.google.android.gms.drive.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }

# Fix R8 Missing Classes
-dontwarn ch.qos.logback.**
-dontwarn io.github.oshai.kotlinlogging.**
-dontwarn org.tinylog.**
-dontwarn com.oracle.svm.**
-dontwarn java.lang.ProcessHandle
-dontwarn java.lang.management.**
-dontwarn javax.naming.**
-dontwarn kotlinx.coroutines.slf4j.**
-dontwarn sun.reflect.**
