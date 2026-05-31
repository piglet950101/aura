import 'dart:io';

import 'package:aura/core/theme/aura_colors.dart';
import 'package:aura/core/theme/aura_radius.dart';
import 'package:aura/core/theme/aura_spacing.dart';
import 'package:aura/core/theme/aura_text_styles.dart';
import 'package:aura/data/auth/auth_repository_provider.dart';
import 'package:aura/data/local/database.dart';
import 'package:aura/data/local/database_provider.dart';
import 'package:aura/features/settings/locale_provider.dart';
import 'package:aura/features/settings/profile_edit_screen.dart';
import 'package:aura/features/settings/settings_providers.dart';
import 'package:aura/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// TODO(marcelo): replace with the real client-side support address before
// store launch. Anyone tapping "Contactar suporte" opens their mail client
// with this as the To: and AURA · Suporte as the subject.
const _kSupportEmail = 'suporte@aura.app';

/// Settings (Definições): profile, language, GDPR data controls, and about.
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

  Future<void> _setLanguage(WidgetRef ref, Locale locale) async {
    ref.read(localeProvider.notifier).state = locale;
    final uid = ref.read(authRepositoryProvider).currentUser?.id;
    if (uid != null) {
      await ref
          .read(auraDatabaseProvider)
          .setProfileLocale(userId: uid, code: localeToCode(locale));
    }
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    final l = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final json = await ref.read(accountServiceProvider).exportJson();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/aura-dados.json');
      await file.writeAsString(json);
      await Share.shareXFiles([XFile(file.path)], subject: l.exportSubject);
    } on Object catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l.exportError(e))));
    }
  }

  Future<void> _contactSupport(BuildContext context, WidgetRef ref) async {
    final l = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    // Build a mailto: URI. We hand-encode the query string because
    // Uri.queryParameters encodes spaces as '+' which most clients show
    // literally in the subject line.
    final subject = Uri.encodeQueryComponent(l.supportEmailSubject);
    final body = await _supportBody(ref);
    final uri = Uri.parse(
      'mailto:$_kSupportEmail?subject=$subject&body=${Uri.encodeQueryComponent(body)}',
    );
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      messenger.showSnackBar(SnackBar(content: Text(l.contactSupport)));
    }
  }

  /// Email body that pre-fills the user's app version + locale + (if known)
  /// their saved profile email, so support replies land in their inbox even
  /// when the device account differs.
  Future<String> _supportBody(WidgetRef ref) async {
    final info = await PackageInfo.fromPlatform();
    final profile = ref.read(profileProvider).valueOrNull;
    final mail = profile?.email;
    return '\n\n---\nAURA v${info.version} (${info.buildNumber})\n'
        '${mail != null && mail.isNotEmpty ? 'email: $mail\n' : ''}';
  }

  Future<void> _rateApp(BuildContext context) async {
    final l = AppL10n.of(context);
    final info = await PackageInfo.fromPlatform();
    final uri = Uri.parse('https://play.google.com/store/apps/details?id=${info.packageName}');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.rateApp)));
    }
  }

  Future<void> _shareApp(BuildContext context) async {
    final l = AppL10n.of(context);
    final info = await PackageInfo.fromPlatform();
    final url = 'https://play.google.com/store/apps/details?id=${info.packageName}';
    await Share.share('${l.shareAppText} $url');
  }

  void _showProComingSoon(BuildContext context) {
    final l = AppL10n.of(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l.proComingSoon), behavior: SnackBarBehavior.floating));
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final l = AppL10n.of(context);
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
        SnackBar(content: Text(l.accountDeleted), behavior: SnackBarBehavior.floating),
      );
    } on Object catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l.deleteError(e))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final profile = ref.watch(profileProvider).valueOrNull;
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l.back,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l.settings, style: AuraTextStyles.screenTitle),
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
            _SectionLabel(l.sectionProfile),
            _Tile(
              icon: Icons.person_outline,
              title: profile?.displayName?.isNotEmpty ?? false
                  ? profile!.displayName!
                  : l.sectionProfile,
              // Once the user fills the email field it's the most useful
              // identifier to surface here (medical report header, support
              // replies). Falls back to the generic descriptor otherwise.
              subtitle: profile?.email?.isNotEmpty ?? false ? profile!.email! : l.profileSubtitle,
              onTap: () => _openProfile(context, profile),
            ),
            const SizedBox(height: AuraSpacing.xl),

            _SectionLabel(l.sectionSupportAndPro),
            _Tile(
              icon: Icons.support_agent_outlined,
              title: l.contactSupport,
              subtitle: l.contactSupportDesc,
              onTap: () => _contactSupport(context, ref),
            ),
            const SizedBox(height: AuraSpacing.sm),
            _Tile(
              icon: Icons.star_outline,
              title: l.rateApp,
              subtitle: l.rateAppDesc,
              onTap: () => _rateApp(context),
            ),
            const SizedBox(height: AuraSpacing.sm),
            _Tile(
              icon: Icons.share_outlined,
              title: l.shareApp,
              subtitle: l.shareAppDesc,
              onTap: () => _shareApp(context),
            ),
            const SizedBox(height: AuraSpacing.sm),
            _Tile(
              icon: Icons.workspace_premium_outlined,
              title: l.unlockPro,
              subtitle: l.unlockProDesc,
              onTap: () => _showProComingSoon(context),
            ),
            const SizedBox(height: AuraSpacing.xl),

            _SectionLabel(l.sectionLanguage),
            _LanguageOption(
              label: l.langPtPt,
              selected: localeToCode(locale) == 'pt-PT',
              onTap: () => _setLanguage(ref, const Locale('pt')),
            ),
            const SizedBox(height: AuraSpacing.sm),
            _LanguageOption(
              label: l.langPtBr,
              selected: localeToCode(locale) == 'pt-BR',
              onTap: () => _setLanguage(ref, const Locale('pt', 'BR')),
            ),
            const SizedBox(height: AuraSpacing.sm),
            _LanguageOption(
              label: l.langEn,
              selected: localeToCode(locale) == 'en',
              onTap: () => _setLanguage(ref, const Locale('en')),
            ),
            const SizedBox(height: AuraSpacing.xl),

            _SectionLabel(l.sectionPrivacyData),
            _PrivacyNote(text: l.privacyNote),
            const SizedBox(height: AuraSpacing.sm),
            _Tile(
              icon: Icons.download_outlined,
              title: l.exportData,
              subtitle: l.exportSubtitle,
              onTap: () => _exportData(context, ref),
            ),
            const SizedBox(height: AuraSpacing.sm),
            _Tile(
              icon: Icons.delete_outline,
              title: l.deleteAccount,
              subtitle: l.deleteAccountSubtitle,
              danger: true,
              onTap: () => _deleteAccount(context, ref),
            ),
            const SizedBox(height: AuraSpacing.xl),

            _SectionLabel(l.sectionAbout),
            _AboutTile(label: l.aboutLine),
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

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AuraRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AuraSpacing.lg),
        decoration: BoxDecoration(
          color: AuraColors.bgRaised,
          border: Border.all(color: selected ? AuraColors.accent : AuraColors.border),
          borderRadius: BorderRadius.circular(AuraRadius.lg),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 20,
              color: selected ? AuraColors.accent : AuraColors.textMuted,
            ),
            const SizedBox(width: AuraSpacing.md),
            Text(
              label,
              style: AuraTextStyles.body.copyWith(
                fontSize: 15,
                color: selected ? AuraColors.textPrimary : AuraColors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AuraSpacing.md),
      decoration: BoxDecoration(
        color: AuraColors.bgRaised,
        border: Border.all(color: AuraColors.border),
        borderRadius: BorderRadius.circular(AuraRadius.md),
      ),
      child: Text(text, style: AuraTextStyles.caption.copyWith(height: 1.4)),
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
  const _AboutTile({required this.label});
  final String label;

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
              Text(label, style: AuraTextStyles.bodySmall),
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
    final l = AppL10n.of(context);
    final word = l.confirmWord;
    final canDelete = _controller.text.trim().toUpperCase() == word.toUpperCase();
    return AlertDialog(
      backgroundColor: AuraColors.bgElevated,
      title: Text(l.deleteAccount, style: AuraTextStyles.screenTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.deleteConfirmBody, style: AuraTextStyles.bodySmall),
          const SizedBox(height: AuraSpacing.md),
          TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(hintText: word),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l.cancel)),
        TextButton(
          onPressed: canDelete ? () => Navigator.of(context).pop(true) : null,
          child: Text(
            l.delete,
            style: TextStyle(color: canDelete ? AuraColors.error : AuraColors.textDisabled),
          ),
        ),
      ],
    );
  }
}
