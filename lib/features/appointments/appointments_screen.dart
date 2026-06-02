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

/// Consulta Médica hub. Layout matches Marcelo's mockup:
///   1. Próxima consulta — upcoming appointment list + inline "+ Agendar"
///   2. Relatório para o médico — two tiles (PDF report + web access code)
///   3. Histórico — past appointments
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

  void _showWebAccessComingSoon(BuildContext context) {
    final l = AppL10n.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.webAccessComingSoon), behavior: SnackBarBehavior.floating),
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
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AuraSpacing.xl,
            AuraSpacing.lg,
            AuraSpacing.xl,
            AuraSpacing.xxl,
          ),
          children: [
            appointmentsAsync.when(
              data: (list) => _AppointmentsBody(
                appointments: list,
                onEdit: (a) => _openEditor(context, existing: a),
                onSchedule: () => _openEditor(context),
                onReport: () => _openReport(context),
                onWebAccess: () => _showWebAccessComingSoon(context),
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

class _AppointmentsBody extends StatelessWidget {
  const _AppointmentsBody({
    required this.appointments,
    required this.onEdit,
    required this.onSchedule,
    required this.onReport,
    required this.onWebAccess,
  });

  final List<Appointment> appointments;
  final void Function(Appointment) onEdit;
  final VoidCallback onSchedule;
  final VoidCallback onReport;
  final VoidCallback onWebAccess;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);

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
        // 1) Próxima consulta
        _SectionLabel(l.sectionUpcoming),
        if (upcoming.isEmpty)
          _EmptyUpcoming(onSchedule: onSchedule)
        else ...[
          for (final a in upcoming)
            Padding(
              padding: const EdgeInsets.only(bottom: AuraSpacing.sm),
              child: _AppointmentTile(appointment: a, onTap: () => onEdit(a)),
            ),
          const SizedBox(height: AuraSpacing.xs),
          _ScheduleButton(label: l.scheduleAppointment, onTap: onSchedule),
        ],
        const SizedBox(height: AuraSpacing.xl),

        // 2) Relatório para o médico
        _SectionLabel(l.sectionReportForDoctor),
        _ReportTile(
          icon: Icons.picture_as_pdf_outlined,
          title: l.reportTitle,
          subtitle: l.generateReportDesc,
          onTap: onReport,
        ),
        const SizedBox(height: AuraSpacing.sm),
        _ReportTile(
          icon: Icons.link_outlined,
          title: l.webAccessCode,
          subtitle: l.webAccessCodeDesc,
          onTap: onWebAccess,
          dim: true,
        ),
        const SizedBox(height: AuraSpacing.xl),

        // 3) Histórico
        if (past.isNotEmpty) ...[
          _SectionLabel(l.sectionPast),
          for (final a in past)
            Padding(
              padding: const EdgeInsets.only(bottom: AuraSpacing.sm),
              child: _AppointmentTile(appointment: a, onTap: () => onEdit(a), dim: true),
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

/// "+ Agendar" inline button shown at the end of the próximas list (mockup
/// style — replaces the FAB which felt disconnected from the section).
class _ScheduleButton extends StatelessWidget {
  const _ScheduleButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(AuraSpacing.tapTargetMin),
        side: const BorderSide(color: AuraColors.accent),
        foregroundColor: AuraColors.accent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AuraRadius.lg)),
      ),
      onPressed: onTap,
      icon: const Icon(Icons.add, size: 20),
      label: Text(label),
    );
  }
}

/// Empty próxima consulta — collapses into a single "Agendar" button so the
/// section never looks abandoned.
class _EmptyUpcoming extends StatelessWidget {
  const _EmptyUpcoming({required this.onSchedule});

  final VoidCallback onSchedule;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(AuraSpacing.lg),
          decoration: BoxDecoration(
            color: AuraColors.bgRaised,
            border: Border.all(color: AuraColors.border),
            borderRadius: BorderRadius.circular(AuraRadius.lg),
          ),
          child: Text(
            l.noAppointmentsBody,
            style: AuraTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AuraSpacing.sm),
        _ScheduleButton(label: l.scheduleAppointment, onTap: onSchedule),
      ],
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.dim = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  /// Faded styling for placeholder/coming-soon tiles (web access code).
  final bool dim;

  @override
  Widget build(BuildContext context) {
    final bg = dim ? AuraColors.bgRaised : AuraColors.accentBg;
    final border = dim ? AuraColors.border : AuraColors.accent;
    final iconColor = dim ? AuraColors.textMuted : AuraColors.accent;
    final titleColor = dim ? AuraColors.textPrimary : AuraColors.accent;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AuraRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AuraSpacing.lg),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(AuraRadius.lg),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 26),
            const SizedBox(width: AuraSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AuraTextStyles.body.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AuraTextStyles.caption),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: iconColor),
          ],
        ),
      ),
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
                  // Client asked to drop the truncation on the consultation
                  // title (no more "Terça-feira, 2 de jun..."). Wraps to a
                  // second line when needed, the tile grows with it.
                  Text(
                    '$date · $time',
                    style: AuraTextStyles.body.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: foreground,
                    ),
                    softWrap: true,
                  ),
                  if (doctor != null || location != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      [if (doctor != null) doctor, if (location != null) location].join(' · '),
                      style: AuraTextStyles.caption.copyWith(color: secondary),
                      softWrap: true,
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
