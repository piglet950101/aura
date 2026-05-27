// Provider for the OutboxWorker. Eager-starts the worker on first read and
// stops it on container disposal. Depends on Supabase being initialized.

import 'package:aura/data/local/database_provider.dart';
import 'package:aura/data/remote/crisis_remote_data_source.dart';
import 'package:aura/data/remote/medication_remote_data_source.dart';
import 'package:aura/data/sync/outbox_worker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final outboxWorkerProvider = Provider<OutboxWorker>((ref) {
  final db = ref.watch(auraDatabaseProvider);
  final supabase = Supabase.instance.client;

  final worker = OutboxWorker(
    database: db,
    crisisRemote: SupabaseCrisisRemoteDataSource(supabase),
    medicationRemote: SupabaseMedicationRemoteDataSource(supabase),
    connectivityStream: Connectivity().onConnectivityChanged,
  )..start();
  ref.onDispose(worker.stop);
  return worker;
});
