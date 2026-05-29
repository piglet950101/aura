import 'package:aura/core/theme/aura_colors.dart';
import 'package:aura/core/theme/aura_radius.dart';
import 'package:aura/core/theme/aura_spacing.dart';
import 'package:aura/core/theme/aura_text_styles.dart';
import 'package:aura/data/local/database.dart';
import 'package:aura/domain/medication/medication_kind.dart';
import 'package:aura/features/medications/medication_edit_screen.dart';
import 'package:aura/features/medications/medications_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Medication catalog list. Reached from the home "Medicação" quick action.
/// Default medication first, then alphabetical. Tap a row to edit; the bottom
/// bar adds a new one.
class MedicationsScreen extends ConsumerWidget {
  const MedicationsScreen({super.key});

  void _openEditor(BuildContext context, {Medication? existing}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MedicationEditScreen(existing: existing),
        fullscreenDialog: existing == null,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medsAsync = ref.watch(activeMedicationsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Voltar',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Medicação', style: AuraTextStyles.screenTitle),
        centerTitle: false,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: medsAsync.when(
                data: (meds) => meds.isEmpty
                    ? const _EmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AuraSpacing.xl,
                          AuraSpacing.lg,
                          AuraSpacing.xl,
                          AuraSpacing.lg,
                        ),
                        itemCount: meds.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AuraSpacing.sm),
                        itemBuilder: (_, i) => _MedicationTile(
                          med: meds[i],
                          onTap: () => _openEditor(context, existing: meds[i]),
                        ),
                      ),
                loading: () => const Center(
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AuraColors.accent),
                  ),
                ),
                error: (e, _) => _ErrorCard(message: '$e'),
              ),
            ),
            _AddBar(onAdd: () => _openEditor(context)),
          ],
        ),
      ),
    );
  }
}

class _MedicationTile extends StatelessWidget {
  const _MedicationTile({required this.med, required this.onTap});

  final Medication med;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kind = MedicationKind.fromCode(med.kind);
    final dose = med.doseMg != null
        ? ' · ${med.doseMg == med.doseMg!.roundToDouble() ? med.doseMg!.toStringAsFixed(0) : med.doseMg}'
              ' mg'
        : '';
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AuraColors.accentBg,
                borderRadius: BorderRadius.circular(AuraRadius.sm),
              ),
              alignment: Alignment.center,
              child: const Text(
                '℞',
                style: TextStyle(
                  color: AuraColors.accent,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AuraSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '${med.name}$dose',
                          style: AuraTextStyles.body.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (med.isDefault) ...[
                        const SizedBox(width: AuraSpacing.sm),
                        const Icon(Icons.star, size: 15, color: AuraColors.accent),
                      ],
                    ],
                  ),
                  const SizedBox(height: AuraSpacing.xs),
                  _KindBadge(kind: kind),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AuraColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _KindBadge extends StatelessWidget {
  const _KindBadge({required this.kind});

  final MedicationKind kind;

  @override
  Widget build(BuildContext context) {
    final isSos = kind == MedicationKind.sos;
    final color = isSos ? AuraColors.intensityHigh : AuraColors.intensityLow;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AuraRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        kind.labelPt,
        style: AuraTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AuraSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.medication_outlined, size: 40, color: AuraColors.textMuted),
            const SizedBox(height: AuraSpacing.lg),
            Text(
              'Sem medicações',
              style: AuraTextStyles.screenTitle.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AuraSpacing.sm),
            const Text(
              'Adiciona os teus medicamentos (SOS ou preventivos) para os '
              'registares rapidamente durante uma crise.',
              style: AuraTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AuraSpacing.xl),
        child: Text(
          'Não foi possível carregar as medicações: $message',
          style: AuraTextStyles.bodySmall.copyWith(color: AuraColors.error),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _AddBar extends StatelessWidget {
  const _AddBar({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AuraSpacing.xl,
        AuraSpacing.md,
        AuraSpacing.xl,
        AuraSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AuraColors.bgBase,
        border: Border(top: BorderSide(color: AuraColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AuraColors.accent,
            foregroundColor: AuraColors.bgBase,
            minimumSize: const Size.fromHeight(AuraSpacing.tapTargetMin),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AuraRadius.lg)),
            elevation: 0,
          ),
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 20),
          label: const Text(
            'Adicionar medicação',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3),
          ),
        ),
      ),
    );
  }
}
