import 'package:aura/data/auth/auth_repository_provider.dart';
import 'package:aura/data/local/database.dart';
import 'package:aura/data/local/database_provider.dart';
import 'package:aura/domain/medication/medication_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Medication catalog writer (create / edit / archive).
final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  return MedicationRepository(
    database: ref.watch(auraDatabaseProvider),
    auth: ref.watch(authRepositoryProvider),
  );
});

/// Reactive list of the signed-in user's active (non-archived) medications,
/// default first then alphabetical.
final activeMedicationsProvider = StreamProvider.autoDispose<List<Medication>>((ref) {
  final db = ref.watch(auraDatabaseProvider);
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) {
    return Stream<List<Medication>>.value(const <Medication>[]);
  }
  return db.watchActiveMedications(user.id);
});
