# ---------------------------------------------------------------------------
# AURA · release-mode keep rules
# ---------------------------------------------------------------------------
# These rules survive R8 minification + resource shrinking when building the
# release APK. Without them, generic type information is erased and any code
# that uses runtime reflection (notably Gson inside flutter_local_notifications)
# blows up with `java.lang.RuntimeException: Missing type parameter`.
# ---------------------------------------------------------------------------

# --- flutter_local_notifications -------------------------------------------
# The plugin uses Gson to (de)serialise NotificationDetails when it persists
# scheduled notifications to SharedPreferences. R8 strips the generic
# signatures Gson reads via TypeToken, so its internal cancel() / schedule()
# / pendingNotificationRequests() throw at runtime once a release build runs.
# Marcelo hit exactly this: "Erro ao salvar: PlatformException(error, Missing
# type parameter, ...) at com.dexterous.flutterlocalnotifications..."
-keep class com.dexterous.** { *; }
-keep class com.dexterous.flutterlocalnotifications.models.** { *; }
-keep class com.dexterous.flutterlocalnotifications.models.styles.** { *; }

# --- Gson (used transitively by flutter_local_notifications) ----------------
# Preserve enough metadata that TypeToken can still resolve generic types
# after minification.
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# --- Drift / sqlite3 --------------------------------------------------------
# Drift drives SQLite via the sqlite3 Dart package; the Android side hits
# system SQLite, but the sqlite_flutter_libs companion bundles a fallback
# library that loads via reflection in some Android versions.
-keep class org.sqlite.** { *; }

# --- Standard Flutter keep rules -------------------------------------------
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# --- Play Core (deferred components) — references but unused ---------------
# The Flutter engine has references to play-core split-install APIs to support
# deferred components. We don't use them, so suppress the missing-class warnings
# that otherwise fail R8 with `Missing class com.google.android.play.core...`.
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# --- Supabase / gotrue / postgrest -----------------------------------------
# The supabase_flutter stack includes Kotlin coroutines + serialization that
# uses reflection in places. Defensive dontwarns so an upstream addition does
# not blow up our release build silently.
-dontwarn kotlin.reflect.**
-dontwarn kotlinx.serialization.**

# --- Drift sqlite3 native loader -------------------------------------------
# sqlite3_flutter_libs falls back to System.loadLibrary in some configurations.
-dontwarn org.sqlite.**
