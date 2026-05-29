-- ===========================================================================
-- AURA · migration 0003 · crisis form redesign (client-agreed)
-- ---------------------------------------------------------------------------
-- Two additive, idempotent changes agreed with the client for the crisis form:
--   1. Allow 'fatigue' (Fadiga) as a symptom code.
--   2. Add crisis_medications.response — the medication efficacy answer
--      (none / partial / total), captured when the app reopens after a dose.
--
-- Aura is now asked as a Sim/Não question in the UI but still stored as the
-- existing 'aura' symptom code, so no schema change is needed for it. Triggers
-- were removed from the form; the crisis_triggers table stays in place
-- (dormant) so no data is dropped.
--
-- Safe to run on a populated database. Run once in the Supabase SQL Editor.
-- ===========================================================================

-- 1. Symptoms: extend the allowed set with 'fatigue'.
alter table public.crisis_symptoms drop constraint if exists crisis_symptoms_symptom_check;
alter table public.crisis_symptoms add constraint crisis_symptoms_symptom_check
  check (symptom in (
    'nausea', 'photophobia', 'phonophobia', 'aura', 'vomiting',
    'dizziness', 'visual_disturbance', 'tingling', 'fatigue', 'other'
  ));

-- 2. Medication response (asked on app reopen, >= 2h after the dose).
alter table public.crisis_medications
  add column if not exists response text
  check (response is null or response in ('none', 'partial', 'total'));

comment on column public.crisis_medications.response is
  'Medication efficacy reported by the user: none / partial / total. Null = not yet recorded.';
