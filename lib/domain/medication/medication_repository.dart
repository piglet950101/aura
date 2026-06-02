// Medication catalog writes — create / edit / archive, each in one Drift
// transaction that also enqueues the sync outbox entry.
//
// The "one default per user" invariant is enforced here AND must survive sync:
// Supabase has a partial unique index (one is_default=true per user). So when
// a medication is promoted to default, any previous default is demoted *and*
// its upsert is enqueued BEFORE the new default's. The outbox drains FIFO, so
// the server clears the old default first and never trips the unique index.

import 'package:aura/data/auth/auth_repository.dart';
import 'package:aura/data/local/database.dart';
import 'package:aura/data/sync/outbox_worker.dart';
import 'package:aura/domain/medication/medication_kind.dart';
import 'package:aura/domain/medication/preventive_subtype.dart';
import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

class MedicationRepository {
  MedicationRepository({
    required AuraDatabase database,
    required AuthRepository auth,
    Uuid uuid = const Uuid(),
  }) : _db = database,
       _auth = auth,
       _uuid = uuid;

  final AuraDatabase _db;
  final AuthRepository _auth;
  final Uuid _uuid;

  /// Creates a new medication (when [id] is null) or updates an existing one.
  /// Returns the medication id. Throws [StateError] if no user is signed in.
  ///
  /// [reminderMinutes] schedules a daily local notification at that minute of
  /// day (0..1439). Only persists on `kind = preventive` + `subtype = pill`
  /// rows; SOS meds and injections ignore it. Pass `null` to clear.
  /// [subtype] is the preventive sub-classification (pill / injection); null
  /// for SOS. [injectionPeriod] is the cadence for injection subtype (mensal
  /// / trimestral); null for pill or SOS.
  Future<String> save({
    required String name,
    required MedicationKind kind,
    required bool isDefault,
    String? id,
    double? doseMg,
    int? reminderMinutes,
    PreventiveSubtype? subtype,
    InjectionPeriod? injectionPeriod,
    DateTime? startedAt,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('MedicationRepository.save called without a signed-in user');
    }
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('medication name cannot be empty');
    }

    final medId = id ?? _uuid.v4();

    await _db.transaction(() async {
      if (isDefault) {
        // Demote any other current default and queue its sync FIRST so the
        // server clears it before the new default upsert (unique-index safe).
        final demoted = await _db.demoteOtherDefaultMedications(userId: user.id, exceptId: medId);
        for (final demotedId in demoted) {
          await _db.enqueueOutbox(
            entityType: OutboxEntityType.medication,
            entityId: demotedId,
            operation: OutboxOperation.upsert,
          );
        }
      }

      // Daily-pill reminders only make sense on `kind = preventive` rows
      // whose subtype is 'pill'. Force-clear them on every other config so
      // a kind/subtype flip doesn't leave a stale alarm firing.
      final isPreventivePill =
          kind == MedicationKind.preventive && subtype == PreventiveSubtype.pill;
      final effectiveReminder = isPreventivePill ? reminderMinutes : null;
      // Subtype / injection period only persist for preventive rows.
      final effectiveSubtype = kind == MedicationKind.preventive ? subtype?.code : null;
      final effectivePeriod = (kind == MedicationKind.preventive && subtype == PreventiveSubtype.injection)
          ? injectionPeriod?.days
          : null;
      // Started date is required for preventives; ignored on SOS rows.
      final effectiveStartedAt = kind == MedicationKind.preventive ? startedAt : null;

      final existing = await _db.findMedication(medId);
      if (existing == null) {
        await _db.insertMedication(
          MedicationsCompanion.insert(
            id: medId,
            userId: user.id,
            name: trimmed,
            doseMg: Value(doseMg),
            kind: Value(kind.code),
            isDefault: Value(isDefault),
            reminderMinutes: Value(effectiveReminder),
            preventiveSubtype: Value(effectiveSubtype),
            injectionPeriodDays: Value(effectivePeriod),
            startedAt: Value(effectiveStartedAt),
          ),
        );
      } else {
        await _db.updateMedicationFields(
          id: medId,
          name: trimmed,
          doseMg: doseMg,
          kind: kind.code,
          isDefault: isDefault,
          reminderMinutes: effectiveReminder,
          preventiveSubtype: effectiveSubtype,
          injectionPeriodDays: effectivePeriod,
          startedAt: effectiveStartedAt,
        );
      }

      await _db.enqueueOutbox(
        entityType: OutboxEntityType.medication,
        entityId: medId,
        operation: OutboxOperation.upsert,
      );
    });

    return medId;
  }

  /// Soft-deletes a medication: archived rows leave the active list / pickers
  /// but stay so historical crisis_medications keep a real reference. An
  /// archived medication can never remain the default.
  Future<void> archive(String id) async {
    await _db.transaction(() async {
      await _db.archiveMedicationById(id);
      await _db.enqueueOutbox(
        entityType: OutboxEntityType.medication,
        entityId: id,
        operation: OutboxOperation.upsert,
      );
    });
  }

  /// Ends an ongoing preventive treatment. The row stays so the user can
  /// still see it in the "Tratamentos terminados" history; reminder is
  /// implicitly cleared by `endTreatment` so the scheduler stops firing it.
  /// Enqueues a sync upsert so the server reflects the end date too.
  Future<void> endTreatment(String id) async {
    await _db.transaction(() async {
      await _db.endTreatment(id);
      await _db.enqueueOutbox(
        entityType: OutboxEntityType.medication,
        entityId: id,
        operation: OutboxOperation.upsert,
      );
    });
  }
}
