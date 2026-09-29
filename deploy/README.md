# Shotgun (Abberton Way)

Static prototype. `index.html` is self-contained.

## Deploy
1. Add `index.html` to the repo root and push.
2. In Vercel: Import the repo → Framework preset "Other" → no build command → Deploy.

## Limits
- Data is stored in each browser's localStorage. Housemates won't see each other's changes.
- "Continue with Google" is a mock. Real sign-in needs Google OAuth plus a shared database (e.g. Supabase).
