# Shotgun

Shared house timetable. Static site on Vercel, Supabase for Google sign-in, database and live sync.

## Setup (once)

1. **Supabase**: create a free project at supabase.com.
2. **Database**: SQL Editor → paste `supabase/schema.sql` → replace the 3 example emails → Run.
3. **Google login**:
   - Google Cloud Console → APIs & Services → Credentials → Create OAuth client ID (Web).
   - Authorised redirect URI: `https://<your-project>.supabase.co/auth/v1/callback`
   - Supabase → Authentication → Sign In / Providers → Google → paste Client ID + Secret → enable.
4. **Redirects**: Supabase → Authentication → URL Configuration → Site URL = your Vercel URL
   (e.g. `https://shotgun.vercel.app`); also add it under Redirect URLs.
5. **Keys**: Supabase → Project Settings → API → copy Project URL + anon public key into `config.js`.
6. Commit and push. Vercel redeploys automatically.

## Adding or changing a housemate's email

Supabase → Table Editor → `members`. Emails must be lowercase.

## Notes

- Free Supabase projects pause after ~7 days of no activity; unpause from the dashboard.
- Anyone can sign in with Google, but only emails in `members` can see or edit data.
