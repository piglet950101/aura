import 'package:aura/data/auth/auth_repository_provider.dart';
import 'package:aura/data/local/database_provider.dart';
import 'package:aura/domain/crisis/crisis_draft.dart';
import 'package:aura/domain/crisis/register_crisis_use_case.dart';
import 'package:aura/domain/crisis/symptom.dart';
import 'package:aura/domain/crisis/trigger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Editable form state for the registration screen. NotifierProvider rather
/// than a plain Provider because we need imperative mutations (tap intensity,
/// toggle a symptom chip) while still letting the UI rebuild reactively.
class CrisisDraftNotifier extends Notifier<CrisisDraft> {
  @override
  CrisisDraft build() => const CrisisDraft();

  void setIntensity(int value) {
    state = state.copyWith(intensity: value);
  }

  void toggleSymptom(Symptom s) {
    final next = Set<Symptom>.from(state.symptoms);
    if (!next.add(s)) next.remove(s);
    state = state.copyWith(symptoms: next);
  }

  /// "Sem sintomas" — clears every symptom chip. Aura (a separate Sim/Não
  /// question) is preserved.
  void clearSymptoms() {
    final next = state.symptoms.where((s) => s == Symptom.aura).toSet();
    state = state.copyWith(symptoms: next);
  }

  /// Aura is stored as the [Symptom.aura] code but asked as Sim/Não.
  void setAura({required bool present}) {
    final next = Set<Symptom>.from(state.symptoms);
    if (present) {
      next.add(Symptom.aura);
    } else {
      next.remove(Symptom.aura);
    }
    state = state.copyWith(symptoms: next);
  }

  void setNotes(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      state = state.copyWith(clearNotes: true);
    } else {
      state = state.copyWith(notes: trimmed);
    }
  }

  void setTrigger(CrisisTrigger? t) {
    if (t == null) {
      state = state.copyWith(clearTrigger: true);
    } else if (state.trigger == t) {
      // Tapping the selected trigger again clears it (toggle behavior).
      state = state.copyWith(clearTrigger: true);
    } else {
      state = state.copyWith(trigger: t);
    }
  }

  void setOccurredAt(DateTime when) {
    state = state.copyWith(occurredAt: when);
  }

  /// Logs a medication chosen from the user's catalog (has a stable id).
  void selectCatalogMedication({required String id, required String name, double? doseMg}) {
    _setMedication(id: id, name: name, doseMg: doseMg);
  }

  /// Logs a common preset medication by name (no catalog id yet — the use
  /// case resolves it to a catalog row, find-or-create, at save time).
  void selectPresetMedication(String name) {
    _setMedication(name: name);
  }

  /// "Nada tomado".
  void clearMedication() {
    state = state.copyWith(clearMedication: true);
  }

  void _setMedication({required String name, String? id, double? doseMg}) {
    // Clear first so a preset (null id) doesn't inherit a previous catalog id
    // via copyWith's null-coalescing.
    state = state
        .copyWith(clearMedication: true)
        .copyWith(takenMedicationId: id, takenMedicationName: name, takenMedicationDoseMg: doseMg);
  }

  void reset() {
    state = const CrisisDraft();
  }

  /// Loads an existing crisis into the draft for editing.
  void hydrate({
    required int intensity,
    required Set<Symptom> symptoms,
    DateTime? occurredAt,
    String? notes,
    String? medicationId,
    String? medicationName,
    double? medicationDoseMg,
    bool? menstruation,
  }) {
    state = CrisisDraft(
      occurredAt: occurredAt,
      intensity: intensity,
      symptoms: symptoms,
      notes: notes,
      takenMedicationId: medicationId,
      takenMedicationName: medicationName,
      takenMedicationDoseMg: medicationDoseMg,
      menstruation: menstruation,
    );
  }

  /// Sim/Não toggle for the hormonal-correlation question — only renders on
  /// the form when the profile says feminino, but stored either way so an
  /// edit of an old crisis doesn't lose a previously captured value.
  void setMenstruation({required bool present}) {
    state = state.copyWith(menstruation: present);
  }

  void clearMenstruation() {
    state = state.copyWith(clearMenstruation: true);
  }
}

final crisisDraftProvider = NotifierProvider<CrisisDraftNotifier, CrisisDraft>(
  CrisisDraftNotifier.new,
);

/// RegisterCrisisUseCase composed with the runtime singletons.
final registerCrisisUseCaseProvider = Provider<RegisterCrisisUseCase>((ref) {
  return RegisterCrisisUseCase(
    database: ref.watch(auraDatabaseProvider),
    auth: ref.watch(authRepositoryProvider),
  );
});
