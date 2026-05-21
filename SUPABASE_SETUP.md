Supabase setup (Flutter)

1. Copy `.env.example` to `.env` at project root and fill values:

   SUPABASE_URL=https://YOUR_PROJECT.supabase.co
   SUPABASE_ANON_KEY=YOUR_ANON_PUBLIC_KEY

2. Install dependencies:

```bash
flutter pub get
```

3. Run the app (debug):

```bash
flutter run
```

4. Notes:
- Do NOT commit `.env` to your repo. `.env.example` is safe to commit.
- Use the `service_role` key only on backend servers, never in client apps.
- If you use CI or build servers, set environment variables there or provide a `.env` during build.
   - If you use CI or build servers, set environment variables there or provide a `.env` during build.

5. Run database migration (SQL)

 - Open Supabase project → SQL Editor → New query and paste the contents of `supabase/migrations/001_init.sql`.
 - Run the query (you may need the `service_role` key or run it from the SQL editor in the dashboard).

6. Create an initial admin user

 - Create a user in Supabase Auth (Auth → Users) with an admin email (e.g., admin@admin.com) and password.
 - Note the user's `id` shown in the Auth Users list.
 - Insert the profile row in SQL Editor (replace <USER_ID> and values):

```sql
INSERT INTO public.profiles (id, full_name, email, role)
VALUES ('<USER_ID>', 'Administrator', 'admin@admin.com', 'admin');
```

7. Tips

 - Use the SQL editor for schema and policies. For production automation, consider the Supabase CLI (`supabase db push`) and storing migrations in a pipeline.
 - After running migrations, test flows: login with an admin user, create doctor/patient accounts, and check table visibility per role.

If you'd like, I can now:
 - Add example login/register flows wired to Supabase in the app.
 - Create example admin pages to create doctor/patient accounts using the Supabase service.
Choose which you prefer and I will implement it next.