# ToolBC release-hardening patch

Patch ini dibuat untuk menutup blocker rilis yang terlihat dari repo publik `diwanparker/toolbc-app`.

Batasan penting:

- Patch ini tidak bisa mencabut API key yang sudah pernah masuk GitHub. Revoke/rotate key Gemini dari Google AI Studio/Google Cloud terlebih dahulu.
- Patch ini tidak bisa menghapus secret dari Git history. Setelah key di-rotate, bersihkan history dengan `git filter-repo` atau BFG Repo-Cleaner bila repo tetap public.
- Patch ini tidak melakukan push ke GitHub. Terapkan patch secara lokal, review diff, lalu commit.

## Cara pakai cepat

Dari root repo lokal `toolbc-app`:

```bash
unzip toolbc_release_hardening_patch.zip
bash toolbc_release_hardening_patch/apply-release-hardening.sh
flutter pub get
flutter analyze
flutter test
```

Build debug lokal tanpa konfigurasi Supabase:

```bash
flutter build apk --debug
```

Build production Android:

```bash
flutter build appbundle --release \
  --dart-define=SUPABASE_URL="https://YOUR_PROJECT.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="YOUR_SUPABASE_ANON_KEY"
```

## Langkah wajib setelah apply

1. Revoke/rotate semua Gemini API key yang pernah ada di repo.
2. Deploy Supabase migration:

```bash
supabase db push
```

3. Set secret Edge Functions:

```bash
supabase secrets set GEMINI_API_KEY="YOUR_NEW_GEMINI_KEY"
supabase secrets set GEMINI_MODEL="gemini-1.5-flash"
```

4. Deploy Edge Functions:

```bash
supabase functions deploy gemini-chat
supabase functions deploy create-account
```

5. Buat Android release keystore dan `android/key.properties` dari `android/key.properties.example`.
6. Review `applicationId` di `android/app/build.gradle.kts`. Patch ini memakai `id.toolbc.app`; ubah sebelum publish bila nama package final berbeda.
7. Jalankan checklist di `RELEASE_CHECKLIST.md` sebelum closed testing.

## File yang diubah/ditambahkan

- Menghapus `flutter_dotenv` dan bundling `.env` dari Flutter asset.
- Menghapus hardcoded Gemini key dari client.
- Mengarahkan chatbot ke Supabase Edge Function `gemini-chat`.
- Menambahkan Edge Function `create-account` untuk admin-side account creation.
- Menambahkan migration awal `profiles` + RLS role dasar.
- Memperbaiki Android release signing config dan package id default.
- Menambahkan GitHub Actions CI dan secret scan sederhana.
- Menambahkan dokumentasi security dan production setup.
