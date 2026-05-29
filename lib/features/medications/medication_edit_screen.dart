import 'package:aura/core/theme/aura_colors.dart';
import 'package:aura/core/theme/aura_radius.dart';
import 'package:aura/core/theme/aura_spacing.dart';
import 'package:aura/core/theme/aura_text_styles.dart';
import 'package:aura/data/local/database.dart';
import 'package:aura/domain/medication/medication_kind.dart';
import 'package:aura/features/medications/medications_providers.dart';
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

  Future<void> _onSave() async {
    if (!_canSave) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(medicationRepositoryProvider)
          .save(
            id: widget.existing?.id,
            name: _name.text,
            doseMg: _parseDose(),
            kind: _kind,
            isDefault: _isDefault,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao guardar: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _onArchive() async {
    final med = widget.existing;
    if (med == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AuraColors.bgElevated,
        title: const Text('Arquivar medicação', style: AuraTextStyles.screenTitle),
        content: const Text(
          'A medicação deixa de aparecer na lista, mas o histórico de crises mantém-se intacto.',
          style: AuraTextStyles.bodySmall,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Arquivar', style: TextStyle(color: AuraColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(medicationRepositoryProvider).archive(med.id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cancelar',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isEdit ? 'Editar medicação' : 'Nova medicação',
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
                    const _SectionLabel('Nome'),
                    TextField(
                      controller: _name,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(hintText: 'Ex.: Sumatriptano'),
                    ),
                    const SizedBox(height: AuraSpacing.xl),

                    const _SectionLabel('Dose (mg) · opcional'),
                    TextField(
                      controller: _dose,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))],
                      decoration: const InputDecoration(hintText: 'Ex.: 50'),
                    ),
                    const SizedBox(height: AuraSpacing.xl),

                    const _SectionLabel('Tipo'),
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
                            'Predefinida',
                            style: AuraTextStyles.body.copyWith(fontSize: 15),
                          ),
                          subtitle: const Text(
                            'Aparece já selecionada ao registar uma crise.',
                            style: AuraTextStyles.caption,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: AuraSpacing.lg),
                        ),
                      ),
                    ),

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
                          label: const Text(
                            'Arquivar medicação',
                            style: TextStyle(color: AuraColors.error),
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
    return Semantics(
      button: true,
      selected: selected,
      label: '${kind.labelPt}, ${kind.descriptionPt}',
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
                    kind.labelPt,
                    style: AuraTextStyles.body.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: selected ? AuraColors.textPrimary : AuraColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AuraSpacing.xs),
              Text(kind.descriptionPt, style: AuraTextStyles.caption),
            ],
          ),
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
              : const Text(
                  'Guardar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                ),
        ),
      ),
    );
  }
}
