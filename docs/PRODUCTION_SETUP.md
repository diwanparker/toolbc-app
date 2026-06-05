# Production Setup

## Flutter configuration

Production builds must pass public Supabase client configuration with dart defines:

```bash
flutter build appbundle --release \
  --dart-define=SUPABASE_URL="https://YOUR_PROJECT.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="YOUR_SUPABASE_ANON_KEY"
```

Do not bundle `.env` into Flutter assets. Do not pass `OPENAI_API_KEY`, `GEMINI_API_KEY_1`, or `GEMINI_API_KEY_2` to Flutter.

## Android signing

Create a release key:

```bash
keytool -genkey -v -keystore android/release-key.jks \
  -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 \
  -alias toolbc-release
```

Copy `android/key.properties.example` to `android/key.properties` and fill passwords. Both files containing key material/passwords must stay out of Git.

> For local testing, the project can fallback to debug signing if `android/key.properties` is missing. For actual Play Store deployment, you still must provide a real release keystore and signing configuration.

## Supabase

Run migrations:

```bash
supabase db push
```

Set Edge Function secrets:

```bash
supabase secrets set GEMINI_API_KEY_1="YOUR_PRIMARY_GEMINI_API_KEY"
supabase secrets set GEMINI_API_KEY_2="YOUR_BACKUP_GEMINI_API_KEY"
supabase secrets set GEMINI_MODEL="gemini-2.5-flash"
supabase secrets set AI_PROVIDER="openai"
supabase secrets set OPENAI_API_KEY="YOUR_OPENAI_API_KEY"
supabase secrets set OPENAI_MODEL="gpt-5-mini"
```

Deploy functions:

```bash
supabase functions deploy gemini-chat
supabase functions deploy create-account
```

## First admin account

Create the first admin manually through Supabase Dashboard or a one-time trusted script. Do not expose public registration for admin creation.

After the first admin exists, use the app admin flow backed by the `create-account` Edge Function to create doctor and patient accounts.

## GitHub Actions

The included workflow runs a simple secret-pattern check, `flutter analyze`, `flutter test`, and a debug APK build. For production signing in CI, use GitHub repository secrets and never commit keystore files.
