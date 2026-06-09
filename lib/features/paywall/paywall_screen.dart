import 'package:aura/core/theme/aura_colors.dart';
import 'package:aura/core/theme/aura_radius.dart';
import 'package:aura/core/theme/aura_spacing.dart';
import 'package:aura/core/theme/aura_text_styles.dart';
import 'package:aura/data/entitlement/entitlement_service_provider.dart';
import 'package:aura/l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// AURA premium paywall. Shown as a full-screen modal route when the user
/// taps a gated feature. Keeps the minimalist clinical aesthetic — no
/// shouty marketing copy, no countdown timers; the value props match the
/// store listing wording (see `Aura.pdf`).
///
/// Wired to [entitlementServiceProvider] via Riverpod; the moment a
/// purchase or restore flips `isPremium` to true, [Navigator.pop] returns
/// `true` so the caller can immediately invoke the originally-tapped
/// action (e.g. share the PDF) without a second tap.
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();

  /// Push the paywall and return whether the user is entitled after it
  /// closes. Callers gate their action on this. The route is full-screen
  /// modal so it composes correctly with deep-link / back-stack handling.
  static Future<bool> push(BuildContext context) async {
    final result = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(fullscreenDialog: true, builder: (_) => const PaywallScreen()));
    return result ?? false;
  }
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _busy = false;

  Future<void> _onPurchase() async {
    if (_busy) return;
    setState(() => _busy = true);
    final svc = ref.read(entitlementServiceProvider);
    final ok = await svc.purchasePremium();
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _onRestore() async {
    if (_busy) return;
    setState(() => _busy = true);
    final l = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final svc = ref.read(entitlementServiceProvider);
    final ok = await svc.restorePurchases();
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      messenger.showSnackBar(SnackBar(content: Text(l.paywallNothingToRestore)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: l.close,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: Text(l.paywallTitle, style: AuraTextStyles.screenTitle),
        centerTitle: false,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AuraSpacing.xl,
            AuraSpacing.md,
            AuraSpacing.xl,
            AuraSpacing.xl,
          ),
          children: [
            Text(l.paywallHeadline, style: AuraTextStyles.body),
            const SizedBox(height: AuraSpacing.sm),
            Text(
              l.paywallSubhead,
              style: AuraTextStyles.bodySmall.copyWith(color: AuraColors.textSecondary),
            ),
            const SizedBox(height: AuraSpacing.xl),
            _Benefit(icon: Icons.picture_as_pdf_outlined, text: l.paywallBenefitReport),
            const SizedBox(height: AuraSpacing.md),
            _Benefit(icon: Icons.insights_outlined, text: l.paywallBenefitStats),
            const SizedBox(height: AuraSpacing.md),
            _Benefit(icon: Icons.history_outlined, text: l.paywallBenefitHistory),
            const SizedBox(height: AuraSpacing.xl),
            _CtaButton(busy: _busy, label: l.paywallCta, onPressed: _onPurchase),
            const SizedBox(height: AuraSpacing.md),
            Center(
              child: TextButton(
                onPressed: _busy ? null : _onRestore,
                child: Text(
                  l.paywallRestore,
                  style: AuraTextStyles.bodySmall.copyWith(color: AuraColors.accent),
                ),
              ),
            ),
            const SizedBox(height: AuraSpacing.md),
            Center(
              child: Text(
                l.paywallFinePrint,
                textAlign: TextAlign.center,
                style: AuraTextStyles.caption.copyWith(color: AuraColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AuraColors.accentBg,
            borderRadius: BorderRadius.circular(AuraRadius.md),
          ),
          child: Icon(icon, size: 18, color: AuraColors.accent),
        ),
        const SizedBox(width: AuraSpacing.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(text, style: AuraTextStyles.body),
          ),
        ),
      ],
    );
  }
}

class _CtaButton extends StatelessWidget {
  const _CtaButton({required this.busy, required this.label, required this.onPressed});
  final bool busy;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: busy ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AuraColors.accent,
          foregroundColor: AuraColors.bgBase,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AuraRadius.md)),
        ),
        child: busy
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: AuraColors.bgBase),
              )
            : Text(label, style: AuraTextStyles.button),
      ),
    );
  }
}
