# ToolBC Release Checklist

## Critical security

- [ ] OpenAI/Gemini keys that were shared or committed previously are revoked/rotated.
- [ ] No OpenAI, Google, or Gemini API key pattern exists in source.
- [ ] Supabase Edge Function secrets include `OPENAI_API_KEY`, `GEMINI_API_KEY_1`, and `GEMINI_API_KEY_2`.
- [ ] No Supabase service role key exists in client directories.
- [ ] `.env` is not bundled as a Flutter asset.
- [ ] Edge Functions hold server-side secrets.
- [ ] Supabase RLS is enabled on patient/doctor/admin tables.
- [ ] A doctor can only access assigned patients.
- [ ] A patient can only access their own data.
- [ ] Admin-only operations are enforced server-side.

## Backend

- [ ] `supabase db push` succeeds on staging.
- [ ] `gemini-chat` Edge Function is deployed.
- [ ] `create-account` Edge Function is deployed.
- [ ] Initial admin account is created manually by project owner.
- [ ] Admin account cannot be created from public registration.

## Mobile release

- [ ] `applicationId` is final.
- [ ] App name and icon are final.
- [ ] Android release keystore exists outside Git.
- [ ] `flutter build appbundle --release` succeeds with production dart-defines.
- [ ] Version code and version name are incremented.
- [ ] Android App Bundle is signed with production key.

## QA

- [ ] `flutter analyze` passes.
- [ ] `flutter test` passes.
- [ ] Admin can create doctor and patient accounts.
- [ ] Doctor login opens doctor dashboard.
- [ ] Patient login opens patient dashboard.
- [ ] Chatbot works only after login.
- [ ] Chatbot refuses diagnosis/dose-change requests.
- [ ] Offline/unconfigured Supabase state has user-friendly error.
- [ ] Password reset/account recovery flow is defined.

## Compliance and product

- [ ] Privacy policy URL exists.
- [ ] Terms/disclaimer states ToolBC is not a replacement for medical diagnosis.
- [ ] Patient consent text is visible before real-data use.
- [ ] Data retention/deletion workflow is documented.
- [ ] Closed testing uses dummy/synthetic data first.
