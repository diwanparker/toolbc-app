# ToolBC App

ToolBC adalah aplikasi Flutter untuk monitoring pengobatan TBC dengan tiga role utama: `admin`, `dokter`, dan `pasien/user`.

## Fitur Utama

- Login memakai Supabase Auth dan role dari tabel `profiles`.
- Admin membuat akun pasien/user dan dokter dari dashboard internal.
- Dokter memantau pasien, adherence, reminder, dan tindak lanjut kasus.
- Pasien melihat progress pengobatan, checkup harian, riwayat, notifikasi, dan chatbot AI.
- Chatbot terhubung ke Gemini untuk menjawab pertanyaan seputar alur aplikasi dan edukasi dasar TBC.

## Struktur Singkat

- `lib/app/`:
  entry widget dan tema aplikasi.
- `lib/core/`:
  model, service, dan komponen UI reusable.
- `lib/features/`:
  halaman per role dan fitur utama aplikasi.

## Menjalankan Proyek

Tooling yang dipakai di repo ini:

- Flutter `3.41.7` via [`.fvmrc`](./.fvmrc)
- Dart `3.11.x`

Langkah lokal:

```bash
fvm flutter pub get
fvm flutter run
```

Login membutuhkan Supabase. Isi `.env` atau jalankan dengan `dart-define`:

```bash
fvm flutter run \
  --dart-define=SUPABASE_URL=your_supabase_url \
  --dart-define=SUPABASE_ANON_KEY=your_supabase_anon_key
```

Jika ingin mengaktifkan chatbot Gemini:

```bash
fvm flutter run \
  --dart-define=GEMINI_API_KEY=your_gemini_api_key
```

## Verifikasi

Perintah yang biasa dipakai untuk validasi:

```bash
fvm flutter analyze
fvm flutter test
fvm flutter build apk --debug
```

## Catatan Role

- Tidak ada register publik.
- Role aktif berasal dari `public.profiles.role`, bukan dari suffix email.
- Dokter dapat meminta admin/resepsionis membuat akun pasien.
- Admin fokus pada manajemen akun pasien/user dan dokter.
- Backend Supabase ada di `supabase/migrations/001_init.sql` dan Edge Function `supabase/functions/create-account`.
