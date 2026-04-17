# Flutter Mobile Emulator Setup & Run

## Current Status
- iOS: Xcode/CocoaPods pending
- Android: SDK cmdline-tools missing, emulator start fail
- Web Mobile: ✅ Ran successfully (iPhone viewport)

## Android Emulator Fix
1. Open Android Studio
2. SDK Manager → SDK Tools → Install `Android SDK Command-line Tools (latest)`
3. Accept licenses: `flutter doctor --android-licenses`
4. AVD Manager → Create/fix Medium_Phone (enable VT-x in BIOS if crash)
5. `flutter emulators --launch Medium_Phone`
6. `flutter run`

## iOS Simulator
1. Enter sudo password for CocoaPods
2. Install Xcode (App Store)
3. `sudo xcode-select ...` (see previous)
4. `cd ios && pod install`
5. `flutter run`

## Quick Mobile (Already Works)
```
flutter run -d chrome --web-browser-flag="--window-size=375,812 --user-agent='iPhone'"
```

App ready for mobile - follow fixes for native emulator!
