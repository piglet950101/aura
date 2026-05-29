// GDPR data rights: export everything as JSON, and delete the account + data.
// Lives in data/ so the Supabase client stays out of the feature/UI layer.

import 'dart:convert';

import 'package:aura/data/auth/auth_repository.dart';
import 'package:aura/data/local/database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountService {
  AccountService({required AuraDatabase database, required AuthRepository auth})
    : _db = database,
      _auth = auth;

  final AuraDatabase _db;
  final AuthRepository _auth;

  // Lazy so unit tests can exercise export without an initialized Supabase.
  SupabaseClient get _client => Supabase.instance.client;

  /// Human-readable JSON of everything stored for the signed-in user — the
  /// GDPR "right to data portability". Generated locally, no server round-trip.
  Future<String> exportJson({DateTime? now}) async {
    final uid = _auth.currentUser?.id ?? '';
    final profile = await _db.getProfile(uid);
    final crises = await _db.allCrisesNewestFirst(userId: uid);

    final crisesJson = <Map<String, dynamic>>[];
    for (final c in crises) {
      final meds = await _db.crisisMedicationsFor(c.id);
      crisesJson.add({
        'id': c.id,
        'occurred_at': c.occurredAt.toUtc().toIso8601String(),
        'intensity': c.intensity,
        'notes': c.notes,
        'symptoms': await _db.symptomsFor(c.id),
        'medications': [
          for (final m in meds)
            {
              'name': m.medicationNameSnapshot,
              'dose_mg': m.doseMg,
              'taken_at': m.takenAt.toUtc().toIso8601String(),
              'response': m.response,
            },
        ],
      });
    }

    final meds = await _db.allMedications(uid);
    final payload = <String, dynamic>{
      'app': 'AURA',
      'exported_at': (now ?? DateTime.now()).toUtc().toIso8601String(),
      'profile': profile == null
          ? null
          : {
              'display_name': profile.displayName,
              'birth_year': profile.birthYear,
              'sex': profile.sex,
            },
      'crises': crisesJson,
      'medications': [
        for (final m in meds)
          {
            'name': m.name,
            'dose_mg': m.doseMg,
            'kind': m.kind,
            'is_default': m.isDefault,
            'archived': m.archived,
          },
      ],
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// GDPR "right to erasure": deletes the user's rows on the server (RLS-scoped;
  /// crises cascade to symptoms / triggers / medications), wipes the local DB,
  /// and starts a fresh anonymous session so the app stays usable.
  Future<void> deleteEverything() async {
    final uid = _auth.currentUser?.id;
    if (uid != null) {
      await _client.from('crises').delete().eq('user_id', uid);
      await _client.from('medications').delete().eq('user_id', uid);
      await _client.from('profiles').delete().eq('id', uid);
    }
    await _db.wipeAllLocalData();
    await _client.auth.signOut();
    await _client.auth.signInAnonymously();
  }
}
