import 'package:aura/core/theme/aura_colors.dart';
import 'package:aura/core/theme/aura_radius.dart';
import 'package:aura/core/theme/aura_spacing.dart';
import 'package:aura/core/theme/aura_text_styles.dart';
import 'package:aura/data/local/database.dart';
import 'package:aura/features/appointments/appointments_providers.dart';
import 'package:aura/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Add or edit a doctor appointment. Date + time are the only required fields;
/// doctor, location and notes are optional but pre-fill the report's "próxima
/// consulta" header when present.
class AppointmentEditScreen extends ConsumerStatefulWidget {
  const AppointmentEditScreen({this.existing, super.key});

  final Appointment? existing;

  @override
  ConsumerState<AppointmentEditScreen> createState() => _AppointmentEditScreenState();
}

class _AppointmentEditScreenState extends ConsumerState<AppointmentEditScreen> {
  late DateTime _date;
  late TimeOfDay _time;
  late final TextEditingController _doctor;
  late final TextEditingController _location;
  late final TextEditingController _notes;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    // Default new appointments to tomorrow 10:00 — sensible "next visit" guess.
    final initial = e?.occursAt ?? DateTime.now().add(const Duration(days: 1));
    _date = DateTime(initial.year, initial.month, initial.day);
    _time = TimeOfDay(hour: initial.hour, minute: initial.minute);
    _doctor = TextEditingController(text: e?.doctorName ?? '');
    _location = TextEditingController(text: e?.location ?? '');
    _notes = TextEditingController(text: e?.notes ?? '');
  }

  @override
  void dispose() {
    _doctor.dispose();
    _location.dispose();
    _notes.dispose();
    super.dispose();
  }

  DateTime get _combined => DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) {
      setState(() => _time = picked);
    }
  }

  Future<void> _onSave() async {
    if (_saving) return;
    final l = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _saving = true);
    try {
      await ref
          .read(appointmentRepositoryProvider)
          .save(
            id: widget.existing?.id,
            occursAt: _combined,
            doctorName: _doctor.text,
            location: _location.text,
            notes: _notes.text,
          );
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(_isEdit ? l.appointmentUpdated : l.appointmentSaved),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      navigator.pop();
    } on Object catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l.saveError(e))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _onDelete() async {
    final id = widget.existing?.id;
    if (id == null) return;
    final l = AppL10n.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AuraColors.bgElevated,
        title: Text(l.deleteAppointmentTitle, style: AuraTextStyles.screenTitle),
        content: Text(l.deleteAppointmentBody, style: AuraTextStyles.bodySmall),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l.cancel)),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.delete, style: const TextStyle(color: AuraColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(appointmentRepositoryProvider).delete(id);
      if (!mounted) return;
      Navigator.of(context).pop();
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.deleteError(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final locale = Localizations.localeOf(context).toString();
    final dateText = DateFormat.yMMMMd(locale).format(_date);
    final timeText = MaterialLocalizations.of(context).formatTimeOfDay(_time);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: l.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isEdit ? l.editAppointment : l.newAppointment,
          style: AuraTextStyles.screenTitle,
        ),
        centerTitle: false,
        actions: [
          if (_isEdit)
            IconButton(
              tooltip: l.delete,
              icon: const Icon(Icons.delete_outline, color: AuraColors.error),
              onPressed: _onDelete,
            ),
        ],
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
                    _Label(l.fieldDate),
                    _PickerTile(
                      icon: Icons.calendar_today_outlined,
                      label: dateText,
                      action: l.selectDate,
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: AuraSpacing.lg),

                    _Label(l.fieldTime),
                    _PickerTile(
                      icon: Icons.access_time,
                      label: timeText,
                      action: l.selectTime,
                      onTap: _pickTime,
                    ),
                    const SizedBox(height: AuraSpacing.xl),

                    _Label(l.fieldDoctor),
                    TextField(
                      controller: _doctor,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(hintText: l.doctorHint),
                    ),
                    const SizedBox(height: AuraSpacing.xl),

                    _Label(l.fieldLocation),
                    TextField(
                      controller: _location,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(hintText: l.locationHint),
                    ),
                    const SizedBox(height: AuraSpacing.xl),

                    _Label(l.fieldAppointmentNotes),
                    TextField(
                      controller: _notes,
                      maxLines: 4,
                      minLines: 2,
                      maxLength: 1000,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(hintText: l.appointmentNotesHint),
                    ),
                    const SizedBox(height: AuraSpacing.xxl),
                  ],
                ),
              ),
            ),
            _SaveBar(saving: _saving, onSave: _onSave, label: l.saveAppointment),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AuraSpacing.md),
      child: Text(text.toUpperCase(), style: AuraTextStyles.sectionLabel),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.label,
    required this.action,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AuraRadius.md),
      child: Container(
        constraints: const BoxConstraints(minHeight: AuraSpacing.tapTargetMin),
        padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.lg, vertical: AuraSpacing.md),
        decoration: BoxDecoration(
          color: AuraColors.bgRaised,
          border: Border.all(color: AuraColors.border),
          borderRadius: BorderRadius.circular(AuraRadius.md),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AuraColors.accent),
            const SizedBox(width: AuraSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AuraTextStyles.body.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AuraColors.textPrimary,
                ),
              ),
            ),
            Text(
              action,
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
  const _SaveBar({required this.saving, required this.onSave, required this.label});

  final bool saving;
  final VoidCallback onSave;
  final String label;

  @override
  Widget build(BuildContext context) {
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
            minimumSize: const Size.fromHeight(AuraSpacing.tapTargetMin),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AuraRadius.lg)),
          ),
          onPressed: saving ? null : onSave,
          child: saving
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: AuraColors.bgBase),
                )
              : Text(
                  label,
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
