# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Razorpay ProGuard rules
-keep class com.razorpay.** { *; }
-keep class com.razorpay.AnalyticsEvent { *; }
-keep class com.razorpay.CheckoutActivity { *; }
-keep class com.razorpay.ExternalWalletCallbackUrl { *; }
-keep class com.razorpay.PaymentData { *; }
-keep class com.razorpay.PaymentResultWithDataListener { *; }
-keep class com.razorpay.RzpTokenReceiver { *; }

# Keep ProGuard annotations
-keep class proguard.annotation.Keep
-keep class proguard.annotation.KeepClassMembers

# Keep classes with ProGuard annotations
-keep @proguard.annotation.Keep class * { *; }
-keepclassmembers class * {
    @proguard.annotation.KeepClassMembers *;
}

# Additional Razorpay rules
-dontwarn com.razorpay.**
-keep class com.razorpay.** { *; }
-keepattributes *Annotation*
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}

# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Google Play Core services rules
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Google Play Store split compatibility
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# If Google Play Core is not used, ignore missing classes
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Additional Flutter embedding rules
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.engine.deferredcomponents.PlayStoreDeferredComponentManager 