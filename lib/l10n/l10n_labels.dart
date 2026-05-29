// Maps domain enums (stored as stable English codes) to localized labels.
// Keeps the enums free of presentation strings and centralizes translation.

import 'package:aura/domain/calendar/month_overview.dart' show IntensityTier;
import 'package:aura/domain/crisis/symptom.dart';
import 'package:aura/domain/medication/medication_kind.dart';
import 'package:aura/domain/medication/pending_medication_response.dart';
import 'package:aura/l10n/app_l10n.dart';

String symptomLabel(AppL10n l, Symptom s) => switch (s) {
  Symptom.nausea => l.symptomNausea,
  Symptom.vomiting => l.symptomVomiting,
  Symptom.photophobia => l.symptomPhotophobia,
  Symptom.phonophobia => l.symptomPhonophobia,
  Symptom.dizziness => l.symptomDizziness,
  Symptom.fatigue => l.symptomFatigue,
  Symptom.other => l.symptomOther,
  Symptom.aura => l.symptomAura,
};

String symptomLabelByCode(AppL10n l, String code) {
  final s = Symptom.fromCode(code);
  return s == null ? code : symptomLabel(l, s);
}

String medicationKindLabel(AppL10n l, MedicationKind k) =>
    k == MedicationKind.sos ? l.kindSos : l.kindPreventive;

String medicationKindDesc(AppL10n l, MedicationKind k) =>
    k == MedicationKind.sos ? l.kindSosDesc : l.kindPreventiveDesc;

String medicationResponseLabel(AppL10n l, MedicationResponse r) => switch (r) {
  MedicationResponse.none => l.respNone,
  MedicationResponse.partial => l.respPartial,
  MedicationResponse.total => l.respTotal,
};

String tierLabel(AppL10n l, IntensityTier t) => switch (t) {
  IntensityTier.none => l.tierSemDor,
  IntensityTier.low => l.legendLeve,
  IntensityTier.med => l.legendModerada,
  IntensityTier.high => l.legendForte,
};
