import 'package:aura/core/theme/aura_colors.dart';
import 'package:aura/core/theme/aura_radius.dart';
import 'package:aura/core/theme/aura_spacing.dart';
import 'package:aura/core/theme/aura_text_styles.dart';
import 'package:aura/data/local/database.dart';
import 'package:aura/features/appointments/appointment_edit_screen.dart';
import 'package:aura/features/appointments/appointments_providers.dart';
import 'package:aura/features/report/report_screen.dart';
import 'package:aura/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Consulta Médica hub. Top card opens the medical-report PDF; below it,
/// "Próximas consultas" + "Passadas" sections list saved appointments.
class AppointmentsScreen extends ConsumerWidget {
  const AppointmentsScreen({super.key});

  void _openReport(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ReportScreen()));
  }

  void _openEditor(BuildContext context, {Appointment? existing}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AppointmentEditScreen(existing: existing),
        fullscreenDialog: existing == null,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final appointmentsAsync = ref.watch(appointmentsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l.back,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l.appointments, style: AuraTextStyles.screenTitle),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AuraColors.accent,
        foregroundColor: AuraColors.bgBase,
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.add),
        label: Text(l.addAppointment),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AuraSpacing.xl,
            AuraSpacing.lg,
            AuraSpacing.xl,
            // Extra bottom padding so the FAB doesn't clip the last item.
            AuraSpacing.xxxl + AuraSpacing.xxl,
          ),
          children: [
            Text(l.appointmentsIntro, style: AuraTextStyles.bodySmall),
            const SizedBox(height: AuraSpacing.lg),
            _ReportCard(onTap: () => _openReport(context)),
            const SizedBox(height: AuraSpacing.xl),
            appointmentsAsync.when(
              data: (list) => _AppointmentsBody(
                appointments: list,
                onTap: (a) => _openEditor(context, existing: a),
              ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AuraSpacing.xxl),
                child: Center(
                  child: SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AuraColors.accent),
                  ),
                ),
              ),
              error: (e, _) =>
                  Text('$e', style: AuraTextStyles.bodySmall.copyWith(color: AuraColors.error)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AuraRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AuraSpacing.lg),
        decoration: BoxDecoration(
          color: AuraColors.accentBg,
          border: Border.all(color: AuraColors.accent),
          borderRadius: BorderRadius.circular(AuraRadius.lg),
        ),
        child: Row(
          children: [
            const Icon(Icons.picture_as_pdf_outlined, color: AuraColors.accent, size: 26),
            const SizedBox(width: AuraSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.generateReport,
                    style: AuraTextStyles.body.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AuraColors.accent,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(l.generateReportDesc, style: AuraTextStyles.caption),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AuraColors.accent),
          ],
        ),
      ),
    );
  }
}

class _AppointmentsBody extends StatelessWidget {
  const _AppointmentsBody({required this.appointments, required this.onTap});

  final List<Appointment> appointments;
  final void Function(Appointment) onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    if (appointments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AuraSpacing.xxl),
        child: Column(
          children: [
            const Icon(Icons.event_outlined, size: 40, color: AuraColors.textMuted),
            const SizedBox(height: AuraSpacing.md),
            Text(
              l.noAppointments,
              style: AuraTextStyles.screenTitle.copyWith(fontSize: 17),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AuraSpacing.sm),
            Text(
              l.noAppointmentsBody,
              style: AuraTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final now = DateTime.now();
    final upcoming = <Appointment>[];
    final past = <Appointment>[];
    for (final a in appointments) {
      if (a.occursAt.isBefore(now)) {
        past.add(a);
      } else {
        upcoming.add(a);
      }
    }
    // Past appointments most-recent first; upcoming stays oldest-first so the
    // closest one is on top.
    past.sort((a, b) => b.occursAt.compareTo(a.occursAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (upcoming.isNotEmpty) ...[
          _SectionLabel(l.sectionUpcoming),
          for (final a in upcoming)
            Padding(
              padding: const EdgeInsets.only(bottom: AuraSpacing.sm),
              child: _AppointmentTile(appointment: a, onTap: () => onTap(a)),
            ),
          const SizedBox(height: AuraSpacing.lg),
        ],
        if (past.isNotEmpty) ...[
          _SectionLabel(l.sectionPast),
          for (final a in past)
            Padding(
              padding: const EdgeInsets.only(bottom: AuraSpacing.sm),
              child: _AppointmentTile(appointment: a, onTap: () => onTap(a), dim: true),
            ),
        ],
      ],
    );
  }
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

class _AppointmentTile extends StatelessWidget {
  const _AppointmentTile({required this.appointment, required this.onTap, this.dim = false});

  final Appointment appointment;
  final VoidCallback onTap;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final dateRaw = DateFormat.yMMMMEEEEd(locale).format(appointment.occursAt);
    final date = dateRaw.isEmpty ? dateRaw : '${dateRaw[0].toUpperCase()}${dateRaw.substring(1)}';
    final time = DateFormat.Hm(locale).format(appointment.occursAt);
    final doctor = appointment.doctorName;
    final location = appointment.location;
    final foreground = dim ? AuraColors.textMuted : AuraColors.textPrimary;
    final secondary = dim ? AuraColors.textDisabled : AuraColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AuraRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AuraSpacing.lg),
        decoration: BoxDecoration(
          color: AuraColors.bgRaised,
          border: Border.all(color: AuraColors.border),
          borderRadius: BorderRadius.circular(AuraRadius.lg),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AuraColors.accentBg,
                borderRadius: BorderRadius.circular(AuraRadius.md),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.event, color: AuraColors.accent.withValues(alpha: dim ? 0.55 : 1)),
            ),
            const SizedBox(width: AuraSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$date · $time',
                    style: AuraTextStyles.body.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: foreground,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (doctor != null || location != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      [if (doctor != null) doctor, if (location != null) location].join(' · '),
                      style: AuraTextStyles.caption.copyWith(color: secondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: secondary),
          ],
        ),
      ),
    );
  }
}
