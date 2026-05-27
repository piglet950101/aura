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

  void reset() {
    state = const CrisisDraft();
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
