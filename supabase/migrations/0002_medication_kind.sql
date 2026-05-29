-- ===========================================================================
-- AURA · migration 0002 · medication kind (sos / preventive)
-- ---------------------------------------------------------------------------
-- Adds the acute-vs-preventive classification to medications. This powers the
-- "Medicação SOS" (acute medication days) overuse metric on the home summary
-- that the client asked for, and the SOS/Preventiva closed-option selector in
-- medication management.
--
-- Safe to run on a populated database: the column is NOT NULL with a default
-- of 'sos', so every existing row is backfilled to 'sos' (rescue) — the
-- sensible default, since meds logged during a crisis are acute by nature.
-- Run once in the Supabase SQL Editor.
-- ===========================================================================

alter table public.medications
  add column if not exists kind text not null default 'sos'
  check (kind in ('sos', 'preventive'));

comment on column public.medications.kind is
  'sos = acute/rescue (taken during a crisis); preventive = daily prophylactic. Drives the acute-medication-days overuse metric.';
