import 'package:aura/core/theme/aura_colors.dart';
import 'package:aura/core/theme/aura_radius.dart';
import 'package:aura/core/theme/aura_spacing.dart';
import 'package:aura/core/theme/aura_text_styles.dart';
import 'package:aura/data/auth/auth_repository_provider.dart';
import 'package:aura/data/local/database.dart';
import 'package:aura/features/settings/settings_providers.dart';
import 'package:aura/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Optional profile used in the clinical PDF header. Nothing here is required.
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({this.existing, super.key});

  final Profile? existing;

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _year;
  String? _sex;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.displayName ?? '');
    _email = TextEditingController(text: widget.existing?.email ?? '');
    _year = TextEditingController(text: widget.existing?.birthYear?.toString() ?? '');
    _sex = widget.existing?.sex;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _year.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (_saving) return;
    final l = AppL10n.of(context);
    setState(() => _saving = true);
    try {
      final userId = ref.read(authRepositoryProvider).currentUser?.id;
      if (userId == null) return;
      final year = int.tryParse(_year.text.trim());
      await ref
          .read(profileRepositoryProvider)
          .save(
            userId: userId,
            displayName: _name.text,
            email: _email.text,
            birthYear: (year != null && year >= 1900 && year <= 2100) ? year : null,
            sex: _sex,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.saveError(e))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final sexes = <(String, String)>[
      ('f', l.sexF),
      ('m', l.sexM),
      ('other', l.sexOther),
      ('na', l.sexNa),
    ];
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: l.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l.profileTitle, style: AuraTextStyles.screenTitle),
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
                    Text(l.profileIntro, style: AuraTextStyles.bodySmall),
                    const SizedBox(height: AuraSpacing.xl),

                    _Label(l.fieldName),
                    TextField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(hintText: l.profileNameHint),
                    ),
                    const SizedBox(height: AuraSpacing.xl),

                    _Label(l.fieldEmail),
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: InputDecoration(hintText: l.emailHint),
                    ),
                    const SizedBox(height: AuraSpacing.xl),

                    _Label(l.fieldBirthYear),
                    TextField(
                      controller: _year,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      decoration: InputDecoration(hintText: l.birthYearHint),
                    ),
                    const SizedBox(height: AuraSpacing.xl),

                    _Label(l.fieldSex),
                    Wrap(
                      spacing: AuraSpacing.sm,
                      runSpacing: AuraSpacing.sm,
                      children: [
                        for (final (code, label) in sexes)
                          _Choice(
                            label: label,
                            selected: _sex == code,
                            onTap: () => setState(() => _sex = _sex == code ? null : code),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _SaveBar(saving: _saving, onSave: _onSave),
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

class _Choice extends StatelessWidget {
  const _Choice({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AuraRadius.md),
      child: Container(
        constraints: const BoxConstraints(minHeight: AuraSpacing.tapTargetMin),
        padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.lg, vertical: AuraSpacing.md),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AuraColors.accentBg : AuraColors.bgRaised,
          border: Border.all(color: selected ? AuraColors.accent : AuraColors.border),
          borderRadius: BorderRadius.circular(AuraRadius.md),
        ),
        child: Text(
          label,
          style: AuraTextStyles.body.copyWith(
            fontSize: 14,
            color: selected ? AuraColors.accent : AuraColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.saving, required this.onSave});

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
                  AppL10n.of(context).save,
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
