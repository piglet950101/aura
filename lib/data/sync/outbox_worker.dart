// AURA · OutboxWorker
// ----------------------------------------------------------------------------
// Drains the local `outbox_entries` queue to Supabase. Triggers on:
//   - explicit start() (typically right after sign-in completes)
//   - every connectivity change to a non-`none` state
//   - a periodic 30s timer as a safety net
//
// Failure handling: exponential backoff per entry, capped at 1 hour. The
// per-entry attempts count lives in the DB so retries survive app restarts.
//
// The class accepts every dependency by constructor so tests inject fakes
// for the remote data sources and a controllable Stream for connectivity.

import 'dart:async';

import 'package:aura/data/local/database.dart';
import 'package:aura/data/remote/crisis_remote_data_source.dart';
import 'package:aura/data/remote/medication_remote_data_source.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Stable string codes used in `outbox_entries.entity_type`.
class OutboxEntityType {
  OutboxEntityType._();
  static const String crisis = 'crisis';
  static const String medication = 'medication';
}

/// Stable string codes used in `outbox_entries.operation`.
class OutboxOperation {
  OutboxOperation._();
  static const String upsert = 'upsert';
  static const String delete = 'delete';
}

class OutboxWorker {
  OutboxWorker({
    required AuraDatabase database,
    required CrisisRemoteDataSource crisisRemote,
    required MedicationRemoteDataSource medicationRemote,
    required Stream<List<ConnectivityResult>> connectivityStream,
    Duration periodic = const Duration(seconds: 30),
    Duration baseBackoff = const Duration(seconds: 5),
    Duration maxBackoff = const Duration(hours: 1),
  }) : _db = database,
       _crisisRemote = crisisRemote,
       _medicationRemote = medicationRemote,
       _connectivityStream = connectivityStream,
       _periodic = periodic,
       _baseBackoff = baseBackoff,
       _maxBackoff = maxBackoff;

  final AuraDatabase _db;
  final CrisisRemoteDataSource _crisisRemote;
  final MedicationRemoteDataSource _medicationRemote;
  final Stream<List<ConnectivityResult>> _connectivityStream;
  final Duration _periodic;
  final Duration _baseBackoff;
  final Duration _maxBackoff;

  Timer? _timer;
  StreamSubscription<List<ConnectivityResult>>? _connSub;
  bool _draining = false;
  bool _started = false;

  /// Idempotent — multiple calls are no-ops.
  void start() {
    if (_started) return;
    _started = true;

    _timer = Timer.periodic(_periodic, (_) => unawaited(drain()));
    _connSub = _connectivityStream.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online) {
        unawaited(drain());
      }
    });

    // Initial drain — picks up anything queued while offline last session.
    unawaited(drain());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _connSub?.cancel();
    _connSub = null;
    _started = false;
  }

  /// Drain one batch of pending entries. Guarded against re-entry; if a
  /// drain is already in flight, the call returns immediately.
  Future<void> drain() async {
    if (_draining) return;
    _draining = true;
    try {
      final pending = await _db.pendingOutbox();
      for (final entry in pending) {
        await _processOne(entry);
      }
    } finally {
      _draining = false;
    }
  }

  Future<void> _processOne(OutboxEntry entry) async {
    try {
      switch (entry.entityType) {
        case OutboxEntityType.crisis:
          await _processCrisis(entry);
        case OutboxEntityType.medication:
          await _processMedication(entry);
        default:
          // Unknown entity type — drop the entry rather than retry forever.
          debugPrint(
            '[OutboxWorker] unknown entity_type=${entry.entityType} '
            'on entry id=${entry.id} — dropping',
          );
      }
      await _db.markOutboxSent(entry.id);
    } on Object catch (e) {
      final backoff = _backoffFor(entry.attempts);
      await _db.markOutboxFailed(
        id: entry.id,
        currentAttempts: entry.attempts,
        error: e.toString(),
        backoff: backoff,
      );
      debugPrint(
        '[OutboxWorker] failed entry id=${entry.id} '
        '(${entry.entityType}/${entry.operation}) — retry in ${backoff.inSeconds}s',
      );
    }
  }

  Future<void> _processCrisis(OutboxEntry entry) async {
    switch (entry.operation) {
      case OutboxOperation.upsert:
        final row = await _db.findCrisis(entry.entityId);
        if (row == null) {
          // Row was deleted locally before sync — nothing to push. Treat as
          // success so the outbox doesn't keep retrying a ghost upsert.
          return;
        }
        // Order matters: parent first (so FKs in crisis_symptoms /
        // crisis_triggers resolve), then the m:n children. The child
        // updates use delete-then-insert so the server reflects the
        // *current* local state without needing a diff.
        await _crisisRemote.upsert(row);
        final symptoms = await _db.symptomsFor(entry.entityId);
        final triggers = await _db.triggersFor(entry.entityId);
        final medications = await _db.crisisMedicationsFor(entry.entityId);
        await _crisisRemote.setSymptoms(entry.entityId, symptoms);
        await _crisisRemote.setTriggers(entry.entityId, triggers);
        await _crisisRemote.setMedications(entry.entityId, medications);
      case OutboxOperation.delete:
        // The Supabase schema has ON DELETE CASCADE on the join tables, so
        // a single delete here removes the symptoms/triggers too.
        await _crisisRemote.delete(entry.entityId);
    }
  }

  Future<void> _processMedication(OutboxEntry entry) async {
    switch (entry.operation) {
      case OutboxOperation.upsert:
        final row = await (_db.select(
          _db.medications,
        )..where((m) => m.id.equals(entry.entityId))).getSingleOrNull();
        if (row == null) return;
        await _medicationRemote.upsert(row);
      case OutboxOperation.delete:
        await _medicationRemote.delete(entry.entityId);
    }
  }

  /// Exponential backoff: base * 2^attempts, clamped to [base, max].
  Duration _backoffFor(int attempts) {
    final shift = attempts.clamp(0, 20);
    final seconds = _baseBackoff.inSeconds * (1 << shift);
    final clamped = seconds.clamp(_baseBackoff.inSeconds, _maxBackoff.inSeconds);
    return Duration(seconds: clamped);
  }
}
