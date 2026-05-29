import 'dart:io';

import 'package:aura/core/theme/aura_colors.dart';
import 'package:aura/core/theme/aura_radius.dart';
import 'package:aura/core/theme/aura_spacing.dart';
import 'package:aura/core/theme/aura_text_styles.dart';
import 'package:aura/data/local/database.dart';
import 'package:aura/features/settings/profile_edit_screen.dart';
import 'package:aura/features/settings/settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Settings (Definições): profile, GDPR data controls, and about.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _openProfile(BuildContext context, Profile? profile) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfileEditScreen(existing: profile),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final json = await ref.read(accountServiceProvider).exportJson();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/aura-dados.json');
      await file.writeAsString(json);
      await Share.shareXFiles([XFile(file.path)], subject: 'Os meus dados · AURA');
    } on Object catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Erro ao exportar: $e')));
    }
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => const _DeleteConfirmDialog(),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await ref.read(accountServiceProvider).deleteEverything();
      ref.invalidate(profileProvider);
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Conta e dados apagados'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on Object catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Erro ao apagar: $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Voltar',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Definições', style: AuraTextStyles.screenTitle),
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
            const _SectionLabel('Perfil'),
            _Tile(
              icon: Icons.person_outline,
              title: profile?.displayName?.isNotEmpty ?? false ? profile!.displayName! : 'Perfil',
              subtitle: 'Nome e dados para o relatório médico',
              onTap: () => _openProfile(context, profile),
            ),
            const SizedBox(height: AuraSpacing.xl),

            const _SectionLabel('Privacidade e dados'),
            const _PrivacyNote(),
            const SizedBox(height: AuraSpacing.sm),
            _Tile(
              icon: Icons.download_outlined,
              title: 'Exportar os meus dados',
              subtitle: 'Recebe tudo em ficheiro JSON',
              onTap: () => _exportData(context, ref),
            ),
            const SizedBox(height: AuraSpacing.sm),
            _Tile(
              icon: Icons.delete_outline,
              title: 'Apagar conta e dados',
              subtitle: 'Remove tudo, sem retorno',
              danger: true,
              onTap: () => _deleteAccount(context, ref),
            ),
            const SizedBox(height: AuraSpacing.xl),

            const _SectionLabel('Sobre'),
            const _AboutTile(),
          ],
        ),
      ),
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

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AuraSpacing.md),
      decoration: BoxDecoration(
        color: AuraColors.bgRaised,
        border: Border.all(color: AuraColors.border),
        borderRadius: BorderRadius.circular(AuraRadius.md),
      ),
      child: Text(
        'Os teus dados ficam no dispositivo e num servidor europeu (Frankfurt), '
        'isolados por utilizador, sem anúncios.',
        style: AuraTextStyles.caption.copyWith(height: 1.4),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AuraColors.error : AuraColors.textPrimary;
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
            Icon(icon, size: 22, color: danger ? AuraColors.error : AuraColors.accent),
            const SizedBox(width: AuraSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AuraTextStyles.body.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AuraTextStyles.caption),
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

class _AboutTile extends StatelessWidget {
  const _AboutTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AuraSpacing.lg),
      decoration: BoxDecoration(
        color: AuraColors.bgRaised,
        border: Border.all(color: AuraColors.border),
        borderRadius: BorderRadius.circular(AuraRadius.lg),
      ),
      child: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snap) {
          final v = snap.hasData ? '${snap.data!.version} (${snap.data!.buildNumber})' : '—';
          return Row(
            children: [
              const Text('AURA · Diário da Enxaqueca', style: AuraTextStyles.bodySmall),
              const Spacer(),
              Text('v$v', style: AuraTextStyles.caption),
            ],
          );
        },
      ),
    );
  }
}

class _DeleteConfirmDialog extends StatefulWidget {
  const _DeleteConfirmDialog();

  @override
  State<_DeleteConfirmDialog> createState() => _DeleteConfirmDialogState();
}

class _DeleteConfirmDialogState extends State<_DeleteConfirmDialog> {
  final _controller = TextEditingController();
  bool get _canDelete => _controller.text.trim().toUpperCase() == 'APAGAR';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AuraColors.bgElevated,
      title: const Text('Apagar conta e dados', style: AuraTextStyles.screenTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Isto apaga permanentemente todas as crises, medicação e perfil, '
            'no dispositivo e no servidor. Para confirmar, escreve APAGAR.',
            style: AuraTextStyles.bodySmall,
          ),
          const SizedBox(height: AuraSpacing.md),
          TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(hintText: 'APAGAR'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _canDelete ? () => Navigator.of(context).pop(true) : null,
          child: Text(
            'Apagar',
            style: TextStyle(color: _canDelete ? AuraColors.error : AuraColors.textDisabled),
          ),
        ),
      ],
    );
  }
}
