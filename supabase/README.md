# Supabase

The AURA Supabase project lives in the **eu-central-1 (Frankfurt)** region.

## Initial setup

1. Create a new Supabase project (`aura-dev` for dev, `aura-prod` for prod).
   Region **must be eu-central-1** — this is irreversible.
2. Open the **SQL Editor** in the Supabase dashboard.
3. Paste the contents of [`migrations/0001_initial_schema.sql`](migrations/0001_initial_schema.sql) and run it.
4. Verify RLS is on for every table:

   ```sql
   select schemaname, tablename, rowsecurity
   from pg_tables
   where schemaname = 'public'
   order by tablename;
   ```

   Every row should show `rowsecurity = true`.

5. Verify the anonymous-user → profile trigger fires correctly:

   ```sql
   -- run from the SQL Editor while logged in as service role
   select count(*) from public.profiles;
   -- then trigger an anonymous sign-in from the app, re-run:
   select count(*) from public.profiles;
   -- the count should have gone up by 1
   ```

## Auth configuration

Open **Authentication → Providers** in the dashboard:

- Email: enabled (default), with magic links allowed.
- **Anonymous sign-ins: ENABLED** — required for the "no-friction first launch" UX. Without this, the app cannot register a crisis before the user enters their email.

Open **Authentication → URL Configuration**:

- Site URL: leave the auto-generated one for dev.
- Redirect URLs: add the app's deep-link scheme once it exists (week 2): `app.aura.diario://auth/callback`.

## Tightening for production

Before submitting `aura-prod`:

- [ ] Set a custom SMTP sender (so password-reset emails come from `support@aura-diario.app`, not Supabase's default).
- [ ] Enable rate limiting on the `signin` endpoint.
- [ ] Set the `JWT expiry` to 7 days for refresh + 1 hour for access.
- [ ] Schedule weekly off-region backups (Supabase **Database → Backups**, paid plan).
- [ ] Set up the RevenueCat webhook receiver as an Edge Function with service-role permission (week 3).

## Migrations going forward

For week 1 we apply migrations manually through the SQL Editor.

Once stable, we'll adopt the Supabase CLI to track migrations in git and run
them in CI. The file naming convention (`NNNN_name.sql`) is already
CLI-compatible, so the switch is mechanical when we make it.
