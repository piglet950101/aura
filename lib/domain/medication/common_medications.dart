/// Common acute (SOS) migraine medications offered as quick presets in the
/// crisis form, in addition to the user's own catalog. Chosen with the client;
/// all are rescue meds, so logging one counts toward the SOS-days metric.
///
/// Selecting a preset that isn't already in the user's catalog creates a
/// catalog entry (kind = sos) at save time — see RegisterCrisisUseCase.
abstract final class CommonMedications {
  CommonMedications._();

  static const List<String> sosPresets = <String>[
    'Ibuprofeno',
    'Paracetamol',
    'Aspirina',
    'Sumatriptano',
    'Rizatriptano',
    'Excedrin',
  ];
}
