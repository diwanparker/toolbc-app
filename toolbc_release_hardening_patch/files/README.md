# ToolBC

ToolBC is a Flutter application for TBC care workflows: account-based access, patient/doctor/admin dashboards, adherence monitoring, checkup support, notification workflows, and an AI education chatbot.

## Runtime configuration

The Flutter client uses Supabase public client configuration via dart defines:

```bash
flutter run \
  --dart-define=SUPABASE_URL="https://YOUR_PROJECT.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="YOUR_SUPABASE_ANON_KEY"
```

The client must not contain Gemini API keys or Supabase service role keys. AI calls go through the `gemini-chat` Supabase Edge Function.

## Account model

There is no public registration. Admin users create doctor and patient accounts through the server-side `create-account` Edge Function. Runtime routing uses the authenticated user's `profiles.role` value.

Supported roles:

- `patient`
- `doctor`
- `admin`

## Local verification

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

## Android release build

```bash
flutter build appbundle --release \
  --dart-define=SUPABASE_URL="https://YOUR_PROJECT.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="YOUR_SUPABASE_ANON_KEY"
```

Configure `android/key.properties` from `android/key.properties.example` before publishing to Play Store.

## Supabase setup

```bash
supabase db push
supabase secrets set GEMINI_API_KEY="YOUR_NEW_GEMINI_KEY"
supabase secrets set GEMINI_MODEL="gemini-1.5-flash"
supabase functions deploy gemini-chat
supabase functions deploy create-account
```

## Release readiness

Use `RELEASE_CHECKLIST.md` before closed testing or production release.
