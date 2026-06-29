# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep JSON parsing models
-keep class com.example.meteomada.model.** { *; }

# Keep Sembast
-keep class com.sembast.** { *; }

# Keep HTTP client
-keep class org.apache.http.** { *; }
-dontwarn org.apache.http.**

# Keep Play Core for deferred components (R8)
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
