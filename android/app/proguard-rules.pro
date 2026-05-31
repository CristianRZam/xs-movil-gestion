# Mantener javax.annotation
-keep class javax.annotation.** { *; }
-dontwarn javax.annotation.**

# Mantener Google Error Prone Annotations
-keep class com.google.errorprone.annotations.** { *; }
-dontwarn com.google.errorprone.annotations.**

# Mantener Tink (usado por flutter_secure_storage)
-keep class com.google.crypto.tink.** { *; }
-dontwarn com.google.crypto.tink.**

# Mantener la anotación @Keep en sí misma
-keep class androidx.annotation.Keep.** { *; }
