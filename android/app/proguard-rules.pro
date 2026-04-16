# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep Kotlin metadata
-keep class kotlin.Metadata { *; }

# Prevent R8 from stripping annotations
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions

# Gson (if used by any dependency)
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Play Core (Flutter deferred components)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**
