import 'package:aura/core/theme/aura_colors.dart';
import 'package:aura/core/theme/aura_radius.dart';
import 'package:aura/core/theme/aura_spacing.dart';
import 'package:aura/core/theme/aura_text_styles.dart';
import 'package:aura/data/report/report_generator.dart';
import 'package:aura/features/report/report_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

/// Clinical report for a doctor visit. Pick a period, preview the PDF, then
/// share or print it from the preview's built-in actions.
class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ref.watch(reportPeriodDaysProvider);
    final dataAsync = ref.watch(reportDataProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Voltar',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Relatório médico', style: AuraTextStyles.screenTitle),
        centerTitle: false,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AuraSpacing.xl,
                AuraSpacing.md,
                AuraSpacing.xl,
                AuraSpacing.sm,
              ),
              child: Row(
                children: [
                  _PeriodChip(
                    label: 'Últimos 30 dias',
                    selected: days == 30,
                    onTap: () => ref.read(reportPeriodDaysProvider.notifier).state = 30,
                  ),
                  const SizedBox(width: AuraSpacing.sm),
                  _PeriodChip(
                    label: 'Últimos 90 dias',
                    selected: days == 90,
                    onTap: () => ref.read(reportPeriodDaysProvider.notifier).state = 90,
                  ),
                ],
              ),
            ),
            Expanded(
              child: dataAsync.when(
                data: (data) => PdfPreview(
                  key: ValueKey(days),
                  build: (format) => const ReportGenerator().generate(data),
                  canChangePageFormat: false,
                  canChangeOrientation: false,
                  canDebug: false,
                  pdfFileName: 'aura-relatorio-${days}d.pdf',
                  loadingWidget: const _Spinner(),
                ),
                loading: () => const _Spinner(),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AuraSpacing.xl),
                  child: Text(
                    'Não foi possível gerar o relatório: $e',
                    style: AuraTextStyles.bodySmall.copyWith(color: AuraColors.error),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AuraRadius.md),
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AuraColors.accentBg : AuraColors.bgRaised,
            border: Border.all(color: selected ? AuraColors.accent : AuraColors.border),
            borderRadius: BorderRadius.circular(AuraRadius.md),
          ),
          child: Text(
            label,
            style: AuraTextStyles.bodySmall.copyWith(
              color: selected ? AuraColors.accent : AuraColors.textSecondary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(strokeWidth: 2, color: AuraColors.accent),
      ),
    );
  }
}
