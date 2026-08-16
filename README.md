# ToolBC App

ToolBC is a Flutter application for TBC care workflows: account-based access, patient/doctor/admin dashboards, adherence monitoring, symptom checkups, notification workflows, and an AI education chatbot.

## Runtime Configuration

The Flutter client communicates with the ToolBC Backend (.NET Web API) using REST APIs. By default, it targets the production Railway backend (`https://toolbc-backend-production.up.railway.app/api`).

To run locally or target a custom backend:

```bash
flutter run \
  --dart-define=API_BASE_URL="http://localhost:5272/api"
```

For Android physical devices connected via USB, run `adb reverse tcp:5272 tcp:5272` or specify your local LAN IP address.

## Account Model

There is no public registration. Admin users create doctor and patient accounts through the `/api/admin/users` endpoint. Runtime routing uses the authenticated user's `role` claim from JWT auth.

Supported roles:
- `patient`
- `doctor`
- `admin`

## Local Verification

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

## Android Release Build

```bash
flutter build appbundle --release \
  --dart-define=API_BASE_URL="https://toolbc-backend-production.up.railway.app/api"
```

Configure `android/key.properties` from `android/key.properties.example` before publishing to Google Play Store.

## Release Readiness

Use `RELEASE_CHECKLIST.md` before closed testing or production release.
