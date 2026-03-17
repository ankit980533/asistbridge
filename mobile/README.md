# AssistBridge Mobile App

Flutter mobile application for AssistBridge platform.

## Requirements

- Flutter 3.0+
- Dart 3.0+
- Android Studio / Xcode

## Setup

1. Install Flutter: https://flutter.dev/docs/get-started/install
2. Clone the repository
3. Run `flutter pub get`
4. Configure Firebase:
   - Create a Firebase project
   - Add Android and iOS apps
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in the respective directories

## Run

```bash
# Development
flutter run

# Build APK
flutter build apk

# Build iOS
flutter build ios
```

## Features

### Visually Impaired Users
- OTP-based authentication
- Voice input for request description
- Automatic location capture
- Request tracking
- Rating system

### Volunteers
- View assigned requests
- Accept and complete requests
- Map navigation to user location
- Call user directly

## Accessibility

The app is designed with accessibility in mind:
- Full VoiceOver (iOS) and TalkBack (Android) support
- Large touch targets (minimum 70px)
- High contrast UI
- Semantic labels on all interactive elements
- Voice input for text fields

## Project Structure

```
lib/
├── main.dart
├── models/
├── providers/
├── screens/
│   ├── auth/
│   ├── user/
│   └── volunteer/
├── services/
├── utils/
└── widgets/
```
