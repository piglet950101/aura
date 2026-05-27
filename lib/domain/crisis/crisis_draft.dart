import 'package:aura/domain/crisis/symptom.dart';
import 'package:aura/domain/crisis/trigger.dart';

/// In-memory form state for the registration screen. Immutable so we can
/// use the standard Riverpod Notifier copy-with pattern.
class CrisisDraft {
  const CrisisDraft({
    this.occurredAt,
    this.intensity,
    this.symptoms = const <Symptom>{},
    this.trigger,
    this.notes,
  });

  /// When the crisis started. Null means "use NOW when saving" — most users
  /// register during or right after the crisis, so we don't force a picker.
  final DateTime? occurredAt;

  /// 1..10, null until the user taps a dot. The save CTA is disabled while
  /// this is null (the only field that *must* be set).
  final int? intensity;

  /// Multi-select.
  final Set<Symptom> symptoms;

  /// Single-select. The mockup shows three options; multi-select looked
  /// cluttered and the aggregate analysis works fine on a single
  /// "most-probable" choice per crisis.
  final CrisisTrigger? trigger;

  final String? notes;

  bool get isSaveable => intensity != null;

  CrisisDraft copyWith({
    DateTime? occurredAt,
    int? intensity,
    Set<Symptom>? symptoms,
    CrisisTrigger? trigger,
    bool clearTrigger = false,
    String? notes,
  }) {
    return CrisisDraft(
      occurredAt: occurredAt ?? this.occurredAt,
      intensity: intensity ?? this.intensity,
      symptoms: symptoms ?? this.symptoms,
      trigger: clearTrigger ? null : (trigger ?? this.trigger),
      notes: notes ?? this.notes,
    );
  }
}
