import 'package:aura/data/auth/auth_repository_provider.dart';
import 'package:aura/data/local/database_provider.dart';
import 'package:aura/domain/medication/medication_response_repository.dart';
import 'package:aura/domain/medication/pending_medication_response.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final medicationResponseRepositoryProvider = Provider<MedicationResponseRepository>((ref) {
  return MedicationResponseRepository(
    database: ref.watch(auraDatabaseProvider),
    auth: ref.watch(authRepositoryProvider),
  );
});

/// The next dose awaiting a "did it work?" answer, or null. The home screen
/// watches this to show the response prompt; invalidate it after recording.
final pendingMedicationResponseProvider = FutureProvider.autoDispose<PendingMedicationResponse?>((
  ref,
) {
  return ref.watch(medicationResponseRepositoryProvider).nextPending();
});
