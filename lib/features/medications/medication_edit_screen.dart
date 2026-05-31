import 'package:aura/core/theme/aura_colors.dart';
import 'package:aura/core/theme/aura_radius.dart';
import 'package:aura/core/theme/aura_spacing.dart';
import 'package:aura/core/theme/aura_text_styles.dart';
import 'package:aura/data/local/database.dart';
import 'package:aura/data/local/database_provider.dart';
import 'package:aura/data/notifications/reminder_service_provider.dart';
import 'package:aura/domain/medication/medication_kind.dart';
import 'package:aura/features/medications/medications_providers.dart';
import 'package:aura/l10n/app_l10n.dart';
import 'package:aura/l10n/l10n_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Add or edit a medication. Reached from the medication list. The kind is a
/// closed two-option selector (SOS / Preventiva) per the client's request —
/// no free text. Marking "predefinida" demotes any previous default.
class MedicationEditScreen extends ConsumerStatefulWidget {
  const MedicationEditScreen({this.existing, super.key});

  final Medication? existing;

  @override
  ConsumerState<MedicationEditScreen> createState() => _MedicationEditScreenState();
}

class _MedicationEditScreenState extends ConsumerState<MedicationEditScreen> {
  late final TextEditingController _name;
  late final TextEditingController _dose;
  late MedicationKind _kind;
  late bool _isDefault;
  TimeOfDay? _reminder;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _dose = TextEditingController(text: e?.doseMg != null ? _formatDose(e!.doseMg!) : '');
    _kind = e != null ? MedicationKind.fromCode(e.kind) : MedicationKind.sos;
    _isDefault = e?.isDefault ?? false;
    final mins = e?.reminderMinutes;
    _reminder = mins == null ? null : TimeOfDay(hour: mins ~/ 60, minute: mins % 60);
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _dose.dispose();
    super.dispose();
  }

  bool get _canSave => _name.text.trim().isNotEmpty && !_saving;

  double? _parseDose() {
    final raw = _dose.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  int? get _reminderMinutes => _reminder == null ? null : _reminder!.hour * 60 + _reminder!.minute;

  Future<void> _pickReminder() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminder ?? const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null) {
      setState(() => _reminder = picked);
    }
  }

  void _clearReminder() => setState(() => _reminder = null);

  Future<void> _onSave() async {
    if (!_canSave) return;
    final l = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final reminderService = ref.read(reminderServiceProvider);
    setState(() => _saving = true);
    try {
      final id = await ref
          .read(medicationRepositoryProvider)
          .save(
            id: widget.existing?.id,
            name: _name.text,
            doseMg: _parseDose(),
            kind: _kind,
            isDefault: _isDefault,
            reminderMinutes: _reminderMinutes,
          );

      // After the row is persisted, reflect the change in the OS scheduler.
      // If we just set a reminder, ask for permission first so the user sees
      // the prompt at the moment that matches their intent.
      final needsScheduling = _kind == MedicationKind.preventive && _reminderMinutes != null;
      if (needsScheduling) {
        final granted = await reminderService.requestPermission();
        if (!granted) {
          messenger.showSnackBar(SnackBar(content: Text(l.notificationPermissionDenied)));
        }
      }
      final fresh = await ref.read(auraDatabaseProvider).findMedication(id);
      if (fresh != null) {
        await reminderService.scheduleForMedication(
          fresh,
          title: l.medsReminderTitle,
          body: l.medsReminderBody(fresh.name),
        );
      }

      if (!mounted) return;
      navigator.pop();
    } on Object catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l.saveError(e))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _onArchive() async {
    final med = widget.existing;
    if (med == null) return;
    final l = AppL10n.of(context);
    final reminderService = ref.read(reminderServiceProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AuraColors.bgElevated,
        title: Text(l.archiveMedication, style: AuraTextStyles.screenTitle),
        content: Text(l.archiveMedBody, style: AuraTextStyles.bodySmall),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l.cancel)),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.archive, style: const TextStyle(color: AuraColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(medicationRepositoryProvider).archive(med.id);
    // Archived rows must stop firing. Repository doesn't know about the OS
    // scheduler — do it from the UI layer where the dependency lives.
    await reminderService.cancelForMedication(med.id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: l.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isEdit ? l.editMedication : l.newMedication,
          style: AuraTextStyles.screenTitle,
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AuraSpacing.xl,
                  AuraSpacing.lg,
                  AuraSpacing.xl,
                  AuraSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SectionLabel(l.fieldName),
                    TextField(
                      controller: _name,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(hintText: l.medNameHint),
                    ),
                    const SizedBox(height: AuraSpacing.xl),

                    _SectionLabel(l.fieldDoseOptional),
                    TextField(
                      controller: _dose,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))],
                      decoration: InputDecoration(hintText: l.doseHint),
                    ),
                    const SizedBox(height: AuraSpacing.xl),

                    _SectionLabel(l.fieldType),
                    _KindSelector(value: _kind, onChanged: (k) => setState(() => _kind = k)),
                    const SizedBox(height: AuraSpacing.xl),

                    Container(
                      decoration: BoxDecoration(
                        color: AuraColors.bgRaised,
                        border: Border.all(color: AuraColors.border),
                        borderRadius: BorderRadius.circular(AuraRadius.lg),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Material(
                        color: Colors.transparent,
                        child: SwitchListTile(
                          value: _isDefault,
                          onChanged: (v) => setState(() => _isDefault = v),
                          activeThumbColor: AuraColors.accent,
                          title: Text(
                            l.defaultMed,
                            style: AuraTextStyles.body.copyWith(fontSize: 15),
                          ),
                          subtitle: Text(l.defaultMedDesc, style: AuraTextStyles.caption),
                          contentPadding: const EdgeInsets.symmetric(horizontal: AuraSpacing.lg),
                        ),
                      ),
                    ),

                    // The daily reminder only makes sense for preventive meds
                    // (taken on a schedule). Hidden completely for SOS to keep
                    // the form lean and avoid setting reminders the scheduler
                    // would ignore anyway.
                    if (_kind == MedicationKind.preventive) ...[
                      const SizedBox(height: AuraSpacing.xl),
                      _SectionLabel(l.fieldReminder),
                      _ReminderTile(
                        reminder: _reminder,
                        onPick: _pickReminder,
                        onClear: _clearReminder,
                      ),
                    ],

                    if (_isEdit) ...[
                      const SizedBox(height: AuraSpacing.xxl),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: _onArchive,
                          icon: const Icon(
                            Icons.archive_outlined,
                            color: AuraColors.error,
                            size: 20,
                          ),
                          label: Text(
                            l.archiveMedication,
                            style: const TextStyle(color: AuraColors.error),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            _SaveBar(enabled: _canSave, saving: _saving, onSave: _onSave),
          ],
        ),
      ),
    );
  }
}

String _formatDose(double dose) {
  // Drop a trailing ".0" so 50.0 shows as "50".
  if (dose == dose.roundToDouble()) return dose.toStringAsFixed(0);
  return dose.toString();
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AuraSpacing.md),
      child: Text(text.toUpperCase(), style: AuraTextStyles.sectionLabel),
    );
  }
}

class _KindSelector extends StatelessWidget {
  const _KindSelector({required this.value, required this.onChanged});

  final MedicationKind value;
  final ValueChanged<MedicationKind> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final k in MedicationKind.values) ...[
          Expanded(
            child: _KindOption(kind: k, selected: k == value, onTap: () => onChanged(k)),
          ),
          if (k != MedicationKind.values.last) const SizedBox(width: AuraSpacing.sm),
        ],
      ],
    );
  }
}

class _KindOption extends StatelessWidget {
  const _KindOption({required this.kind, required this.selected, required this.onTap});

  final MedicationKind kind;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: '${medicationKindLabel(l, kind)}, ${medicationKindDesc(l, kind)}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AuraRadius.lg),
        child: Container(
          constraints: const BoxConstraints(minHeight: AuraSpacing.tapTargetMin),
          padding: const EdgeInsets.symmetric(vertical: AuraSpacing.md, horizontal: AuraSpacing.md),
          decoration: BoxDecoration(
            color: selected ? AuraColors.accentBg : AuraColors.bgRaised,
            border: Border.all(
              color: selected ? AuraColors.accent : AuraColors.border,
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(AuraRadius.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    selected ? Icons.radio_button_checked : Icons.radio_button_off,
                    size: 18,
                    color: selected ? AuraColors.accent : AuraColors.textMuted,
                  ),
                  const SizedBox(width: AuraSpacing.sm),
                  Text(
                    medicationKindLabel(l, kind),
                    style: AuraTextStyles.body.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: selected ? AuraColors.textPrimary : AuraColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AuraSpacing.xs),
              Text(medicationKindDesc(l, kind), style: AuraTextStyles.caption),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({required this.reminder, required this.onPick, required this.onClear});

  final TimeOfDay? reminder;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final mat = MaterialLocalizations.of(context);
    final hasReminder = reminder != null;
    final label = hasReminder ? l.reminderAt(mat.formatTimeOfDay(reminder!)) : l.reminderNone;
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(AuraRadius.md),
      child: Container(
        constraints: const BoxConstraints(minHeight: AuraSpacing.tapTargetMin),
        padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.lg, vertical: AuraSpacing.md),
        decoration: BoxDecoration(
          color: AuraColors.bgRaised,
          border: Border.all(color: hasReminder ? AuraColors.accent : AuraColors.border),
          borderRadius: BorderRadius.circular(AuraRadius.md),
        ),
        child: Row(
          children: [
            Icon(
              hasReminder ? Icons.alarm_on : Icons.alarm_off,
              size: 22,
              color: hasReminder ? AuraColors.accent : AuraColors.textMuted,
            ),
            const SizedBox(width: AuraSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AuraTextStyles.body.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: hasReminder ? AuraColors.textPrimary : AuraColors.textSecondary,
                ),
              ),
            ),
            if (hasReminder)
              TextButton(
                onPressed: onClear,
                style: TextButton.styleFrom(
                  foregroundColor: AuraColors.textMuted,
                  padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.sm),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(l.reminderClear, style: AuraTextStyles.caption),
              )
            else
              Text(
                l.reminderSet,
                style: AuraTextStyles.caption.copyWith(
                  color: AuraColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.enabled, required this.saving, required this.onSave});

  final bool enabled;
  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AuraSpacing.xl,
        AuraSpacing.md,
        AuraSpacing.xl,
        AuraSpacing.xl,
      ),
      decoration: const BoxDecoration(
        color: AuraColors.bgBase,
        border: Border(top: BorderSide(color: AuraColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AuraColors.accent,
            foregroundColor: AuraColors.bgBase,
            disabledBackgroundColor: AuraColors.bgElevated,
            disabledForegroundColor: AuraColors.textMuted,
            minimumSize: const Size.fromHeight(AuraSpacing.tapTargetMin),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AuraRadius.lg)),
          ),
          onPressed: enabled ? onSave : null,
          child: saving
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: AuraColors.bgBase),
                )
              : Text(
                  l.save,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}
