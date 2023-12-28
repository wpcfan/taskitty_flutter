#Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# You might not be using firebase
-keep class com.google.firebase.** { *; }
-keep class com.builttoroam.devicecalendar.** { *; }
// You can specify any path and filename.
-printconfiguration ~/tmp/full-r8-config.txt