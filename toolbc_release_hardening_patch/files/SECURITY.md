# Security Policy

ToolBC handles health-related user data. Treat every patient profile, checkup entry, adherence log, notification, and doctor assignment as sensitive data.

## Secret handling

Never commit API keys, service role keys, keystores, passwords, or `.env` files. Client applications may contain Supabase URL and anon key, but they must not contain Gemini API keys or Supabase service role keys.

Server-side secrets must be stored in Supabase Edge Function secrets or another controlled backend secret manager.

## Rotating leaked keys

If a key is committed to GitHub:

1. Revoke or rotate the key immediately.
2. Replace it in Supabase/CI secret storage.
3. Remove it from source code.
4. Clean Git history with `git filter-repo` or BFG Repo-Cleaner when the repository remains public.
5. Audit access logs for suspicious usage.

## Reporting issues

Report security issues privately to the repository owner. Do not disclose patient data, keys, screenshots of private dashboards, or exploit details publicly.
