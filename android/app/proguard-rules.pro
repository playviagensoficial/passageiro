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

# Stripe Android SDK Rules
-keep class com.stripe.android.** { *; }
-keep class com.stripe.android.pushProvisioning.** { *; }
-keep class com.stripe.android.customersheet.** { *; }
-keep class com.stripe.android.paymentsheet.** { *; }

# Keep Stripe push provisioning classes specifically
-keep class com.stripe.android.pushProvisioning.PushProvisioningActivity** { *; }
-keep class com.stripe.android.pushProvisioning.PushProvisioningActivityStarter** { *; }
-keep class com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider** { *; }

# React Native Stripe SDK
-keep class com.reactnativestripesdk.** { *; }

# Keep all enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep Parcelable classes
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Google Play Core
-keep class com.google.android.play.core.** { *; }

# Don't warn about missing classes
-dontwarn com.stripe.android.pushProvisioning.**
-dontwarn com.reactnativestripesdk.**
-dontwarn com.google.android.play.core.**