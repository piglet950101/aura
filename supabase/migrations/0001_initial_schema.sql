-- ===========================================================================
-- AURA · initial schema · migration 0001
-- ---------------------------------------------------------------------------
-- Run this once in the Supabase SQL Editor against a fresh project.
-- All tables sit in the default `public` schema. RLS is enabled on every
-- table; every policy filters by auth.uid() = user_id. Anonymous Supabase
-- sessions are first-class citizens — anonymous users own their own rows
-- and can later be upgraded to identified email accounts without losing data.
--
-- Idempotency: this file is meant to be run once. Re-running it will error
-- on duplicate object names. If you need to re-bootstrap, drop the schema
-- and rerun. There is no DROP at the top by design — accidental
-- destruction of a populated database is not a tradeoff worth making.
-- ===========================================================================

-- ---------------------------------------------------------------------------
-- Extensions
-- ---------------------------------------------------------------------------
create extension if not exists "pgcrypto";   -- gen_random_uuid()

-- ---------------------------------------------------------------------------
-- updated_at trigger helper
-- ---------------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- profiles · one row per auth user
-- ---------------------------------------------------------------------------
create table public.profiles (
  id           uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  birth_year   smallint check (birth_year is null or birth_year between 1900 and 2100),
  sex          text check (sex is null or sex in ('f', 'm', 'other', 'na')),
  locale       text not null default 'pt-PT',
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);
comment on table  public.profiles is 'One row per auth user. Optional demographic context shown in the PDF report header.';

create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- medications · user-managed drug list, soft-archive instead of delete
-- ---------------------------------------------------------------------------
create table public.medications (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users(id) on delete cascade,
  name       text not null check (length(name) > 0 and length(name) <= 80),
  dose_mg    numeric check (dose_mg is null or dose_mg > 0),
  is_default boolean not null default false,
  archived   boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.medications is 'User-managed drug list. Archived rows stay so historical crisis_medications keep referring to a real row.';

create index medications_user_active_idx on public.medications (user_id) where archived = false;

create trigger medications_set_updated_at
  before update on public.medications
  for each row execute function public.set_updated_at();

-- A user can have at most one default medication at a time.
create unique index medications_one_default_per_user_idx
  on public.medications (user_id)
  where is_default = true and archived = false;

-- ---------------------------------------------------------------------------
-- crises · the event log
-- ---------------------------------------------------------------------------
create table public.crises (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  occurred_at timestamptz not null,
  intensity   smallint not null check (intensity between 1 and 10),
  location    text check (location is null or length(location) <= 40),
  notes       text check (notes is null or length(notes) <= 1000),
  resolved_at timestamptz check (resolved_at is null or resolved_at >= occurred_at),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);
comment on table public.crises is 'Migraine crisis event. occurred_at is when the pain started; resolved_at is optional (when pain ended).';

create index crises_user_recent_idx on public.crises (user_id, occurred_at desc);

create trigger crises_set_updated_at
  before update on public.crises
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- crisis_symptoms · many-to-many between crises and a fixed symptom enum
-- ---------------------------------------------------------------------------
create table public.crisis_symptoms (
  crisis_id uuid not null references public.crises(id) on delete cascade,
  symptom   text not null check (symptom in (
    'nausea', 'photophobia', 'phonophobia', 'aura', 'vomiting',
    'dizziness', 'visual_disturbance', 'tingling', 'other'
  )),
  primary key (crisis_id, symptom)
);
comment on table public.crisis_symptoms is 'Symptoms reported with a crisis. Codes are stable English identifiers; UI translates at the presentation layer.';

-- ---------------------------------------------------------------------------
-- crisis_triggers · many-to-many between crises and a fixed trigger enum
-- ---------------------------------------------------------------------------
create table public.crisis_triggers (
  crisis_id uuid not null references public.crises(id) on delete cascade,
  trigger   text not null check (trigger in (
    'stress', 'sleep', 'weather', 'food', 'hormonal',
    'screen', 'exercise', 'dehydration', 'alcohol', 'other'
  )),
  primary key (crisis_id, trigger)
);
comment on table public.crisis_triggers is 'Likely triggers identified by the user for a crisis. Stable English codes, UI translates at the presentation layer.';

-- ---------------------------------------------------------------------------
-- crisis_medications · medication taken during a crisis + response
-- ---------------------------------------------------------------------------
create table public.crisis_medications (
  id                       uuid primary key default gen_random_uuid(),
  crisis_id                uuid not null references public.crises(id) on delete cascade,
  medication_id            uuid references public.medications(id) on delete set null,
  medication_name_snapshot text not null check (length(medication_name_snapshot) > 0),
  dose_mg                  numeric check (dose_mg is null or dose_mg > 0),
  taken_at                 timestamptz not null,
  relief_at                timestamptz check (relief_at is null or relief_at >= taken_at),
  effective                boolean
);
comment on table public.crisis_medications is 'Medication dose taken during a crisis. Name is snapshotted so deleting a medication does not corrupt historical reports.';

create index crisis_medications_by_crisis_idx on public.crisis_medications (crisis_id);

-- ---------------------------------------------------------------------------
-- subscriptions_cache · mirrors RevenueCat entitlement state
-- ---------------------------------------------------------------------------
create table public.subscriptions_cache (
  user_id        uuid primary key references auth.users(id) on delete cascade,
  is_premium     boolean not null default false,
  product_id     text,
  expires_at     timestamptz,
  rc_app_user_id text,
  updated_at     timestamptz not null default now()
);
comment on table public.subscriptions_cache is 'Server-side mirror of RevenueCat entitlements, fed by RevenueCat webhooks. The client treats RevenueCat as the source of truth; this cache is for server queries / analytics.';

create trigger subscriptions_cache_set_updated_at
  before update on public.subscriptions_cache
  for each row execute function public.set_updated_at();

-- ===========================================================================
-- Row-level security
-- Every table filters by auth.uid() = user_id (or maps through it).
-- ===========================================================================

-- profiles
alter table public.profiles enable row level security;
create policy profiles_owner_select on public.profiles for select using (auth.uid() = id);
create policy profiles_owner_insert on public.profiles for insert with check (auth.uid() = id);
create policy profiles_owner_update on public.profiles for update using (auth.uid() = id);
create policy profiles_owner_delete on public.profiles for delete using (auth.uid() = id);

-- medications
alter table public.medications enable row level security;
create policy medications_owner_select on public.medications for select using (auth.uid() = user_id);
create policy medications_owner_insert on public.medications for insert with check (auth.uid() = user_id);
create policy medications_owner_update on public.medications for update using (auth.uid() = user_id);
create policy medications_owner_delete on public.medications for delete using (auth.uid() = user_id);

-- crises
alter table public.crises enable row level security;
create policy crises_owner_select on public.crises for select using (auth.uid() = user_id);
create policy crises_owner_insert on public.crises for insert with check (auth.uid() = user_id);
create policy crises_owner_update on public.crises for update using (auth.uid() = user_id);
create policy crises_owner_delete on public.crises for delete using (auth.uid() = user_id);

-- crisis_symptoms (filter via crisis ownership)
alter table public.crisis_symptoms enable row level security;
create policy crisis_symptoms_owner_select on public.crisis_symptoms
  for select using (exists (select 1 from public.crises c where c.id = crisis_id and c.user_id = auth.uid()));
create policy crisis_symptoms_owner_insert on public.crisis_symptoms
  for insert with check (exists (select 1 from public.crises c where c.id = crisis_id and c.user_id = auth.uid()));
create policy crisis_symptoms_owner_update on public.crisis_symptoms
  for update using (exists (select 1 from public.crises c where c.id = crisis_id and c.user_id = auth.uid()));
create policy crisis_symptoms_owner_delete on public.crisis_symptoms
  for delete using (exists (select 1 from public.crises c where c.id = crisis_id and c.user_id = auth.uid()));

-- crisis_triggers (same pattern as crisis_symptoms)
alter table public.crisis_triggers enable row level security;
create policy crisis_triggers_owner_select on public.crisis_triggers
  for select using (exists (select 1 from public.crises c where c.id = crisis_id and c.user_id = auth.uid()));
create policy crisis_triggers_owner_insert on public.crisis_triggers
  for insert with check (exists (select 1 from public.crises c where c.id = crisis_id and c.user_id = auth.uid()));
create policy crisis_triggers_owner_update on public.crisis_triggers
  for update using (exists (select 1 from public.crises c where c.id = crisis_id and c.user_id = auth.uid()));
create policy crisis_triggers_owner_delete on public.crisis_triggers
  for delete using (exists (select 1 from public.crises c where c.id = crisis_id and c.user_id = auth.uid()));

-- crisis_medications (same pattern)
alter table public.crisis_medications enable row level security;
create policy crisis_medications_owner_select on public.crisis_medications
  for select using (exists (select 1 from public.crises c where c.id = crisis_id and c.user_id = auth.uid()));
create policy crisis_medications_owner_insert on public.crisis_medications
  for insert with check (exists (select 1 from public.crises c where c.id = crisis_id and c.user_id = auth.uid()));
create policy crisis_medications_owner_update on public.crisis_medications
  for update using (exists (select 1 from public.crises c where c.id = crisis_id and c.user_id = auth.uid()));
create policy crisis_medications_owner_delete on public.crisis_medications
  for delete using (exists (select 1 from public.crises c where c.id = crisis_id and c.user_id = auth.uid()));

-- subscriptions_cache · the client only reads; webhook (service role) writes.
alter table public.subscriptions_cache enable row level security;
create policy subscriptions_cache_owner_select on public.subscriptions_cache
  for select using (auth.uid() = user_id);
-- NOTE: no insert/update/delete policies for end users. Writes happen via
--       the RevenueCat webhook Edge Function which runs with service_role.

-- ===========================================================================
-- Auto-create a profile row whenever a new auth user signs up (anonymous
-- or identified). This keeps the profiles row in lockstep with auth.users.
-- ===========================================================================
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id) values (new.id) on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ===========================================================================
-- Done. To verify in psql or SQL Editor:
--   select schemaname, tablename, rowsecurity
--   from pg_tables where schemaname='public' order by tablename;
-- Every public table should show rowsecurity = true.
-- ===========================================================================
