-keep class com.yalantis.ucrop** { *; }
-keep interface com.yalantis.ucrop** { *; }

# Unity Ads ProGuard rules
-keepattributes SourceFile,LineNumberTable
-keepattributes JavascriptInterface
-keep class com.unity3d.ads.** { *; }
-keep interface com.unity3d.ads.** { *; }

# Unity Services
-keep class com.unity3d.services.** { *; }
-keep interface com.unity3d.services.** { *; }