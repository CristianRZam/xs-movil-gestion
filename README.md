# maxima

A new Flutter project.

## Generate and update splash screen
```
dart run flutter_native_splash:create
```

## Getting Started

Run
```
flutter clean
flutter pub get
dart run flutter_gen:flutter_gen_command
dart run build_runner build --delete-conflicting-outputs
dart run build_runner build
```

## Generate Archive Play Store
```
flutter build appbundle --release

```

## Important: Signing Keys
```
This project uses a **release keystore** to sign the Android app. These files are **not included in the repository** for security reasons.

To build a release APK or App Bundle, you need to:

1. Place your `upload-keystore.jks` file in `android/app/` (do **not** commit this file).
2. Create a `key.properties` file in `android/` with the following content:
```