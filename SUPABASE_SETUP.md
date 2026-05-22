# Supabase Setup

ToolBC sekarang memakai Supabase sebagai backend utama. Tidak ada mode demo login:
akun harus ada di Supabase Auth dan mempunyai row di `public.profiles`.

## 1. Environment Flutter

Buat `.env` di root project:

```env
SUPABASE_URL=https://YOUR_PROJECT.supabase.co
SUPABASE_ANON_KEY=YOUR_ANON_PUBLIC_KEY
```

Atau jalankan dengan `dart-define`:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_PUBLIC_KEY
```

## 2. Database

Jalankan SQL migration:

```bash
supabase db push
```

Atau paste isi `supabase/migrations/001_init.sql` ke Supabase SQL Editor.

## 3. Edge Function

Deploy function admin account creation:

```bash
supabase functions deploy create-account
```

Function ini memakai `SERVICE_ROLE_KEY` pada environment Supabase Function
untuk membuat Auth user dan menulis `profiles` / `patients_data`.
Jangan pernah menaruh service role key di aplikasi Flutter.

Set secret (CLI):

```bash
supabase secrets set SERVICE_ROLE_KEY=YOUR_SERVICE_ROLE_KEY
```

## 4. Initial Admin

Buat satu admin pertama dari Supabase Dashboard:

1. Auth > Users > Add user.
2. Pakai email admin produksi milik klinik.
3. Copy user `id`.
4. Jalankan SQL berikut dengan data yang sesuai:

```sql
insert into public.profiles (id, full_name, email, role)
values ('<USER_ID>', '<NAMA_ADMIN>', '<EMAIL_ADMIN>', 'admin')
on conflict (id) do update set
  full_name = excluded.full_name,
  email = excluded.email,
  role = 'admin',
  updated_at = now();
```

## 5. Cleanup Demo Accounts

Jika project Supabase lama sudah berisi akun dummy, review lalu jalankan:

```sql
-- supabase/cleanup/remove_demo_accounts.sql
```

Script cleanup hanya menargetkan nama/email demo lama. Jangan perluas filter tanpa
backup database.
