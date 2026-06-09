import 'dart:async';

import 'package:aura/domain/entitlement/entitlement.dart';
import 'package:aura/domain/entitlement/entitlement_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:purchases_flutter/purchases_flutter.dart';

/// RevenueCat-backed entitlement service.
///
/// Init contract: call `init` exactly once during bootstrap, *after*
/// Supabase auth has resolved the current user so [appUserId] is stable.
/// Re-init on user switch (anonymous → email upgrade) is safe — the SDK
/// re-aliases the underlying customer.
///
/// Configuration:
///   - `RC_ANDROID_KEY` / `RC_IOS_KEY` come from env.dev.json /
///     env.prod.json via `--dart-define-from-file` (NOT committed).
///   - `RC_ENTITLEMENT_ID` is the entitlement identifier configured in the
///     RevenueCat dashboard (e.g. `aura_premium`). Defaults to `premium`.
///   - `RC_OFFERING_ID` is the offering to surface on the paywall; null
///     means "current offering" from the dashboard.
///
/// Until Marcelo provisions the RC dashboard + sends the API keys, the
/// provider falls back to `MockEntitlementService` so dev/QA isn't blocked.
class RevenueCatEntitlementService implements EntitlementService {
  RevenueCatEntitlementService({
    required this.androidApiKey,
    required this.iosApiKey,
    required this.entitlementId,
    required this.appUserId,
    this.offeringId,
  });

  final String androidApiKey;
  final String iosApiKey;
  final String entitlementId;
  final String? offeringId;
  final String? appUserId;

  final _controller = StreamController<EntitlementStatus>.broadcast();
  EntitlementStatus _status = const EntitlementStatus.free();

  @override
  EntitlementStatus get current => _status;

  @override
  Stream<EntitlementStatus> watch() async* {
    yield _status;
    yield* _controller.stream;
  }

  /// Wire the RevenueCat SDK and seed the first entitlement snapshot.
  /// Errors here are non-fatal — the user falls back to "free" rather than
  /// the app refusing to launch.
  Future<void> init() async {
    try {
      final config = PurchasesConfiguration(
        defaultTargetPlatform == TargetPlatform.iOS ? iosApiKey : androidApiKey,
      );
      if (appUserId != null && appUserId!.isNotEmpty) {
        config.appUserID = appUserId;
      }
      await Purchases.configure(config);
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfo);
      final info = await Purchases.getCustomerInfo();
      _onCustomerInfo(info);
    } on Object catch (e, st) {
      debugPrint('[AURA] RevenueCat init failed (non-fatal): $e\n$st');
      // Keep the free default; never throw out of bootstrap for billing.
    }
  }

  void _onCustomerInfo(CustomerInfo info) {
    final ent = info.entitlements.active[entitlementId];
    final active = ent != null;
    final next = EntitlementStatus(isPremium: active, source: active ? 'rc-active' : 'rc-inactive');
    if (next.isPremium == _status.isPremium && next.source == _status.source) return;
    _status = next;
    _controller.add(_status);
  }

  @override
  Future<bool> purchasePremium() async {
    try {
      final offerings = await Purchases.getOfferings();
      final offering = offeringId != null ? offerings.getOffering(offeringId!) : offerings.current;
      final pkg = offering?.availablePackages.firstOrNull;
      if (pkg == null) {
        debugPrint('[AURA] purchasePremium: no package available');
        return false;
      }
      final info = await Purchases.purchasePackage(pkg);
      _onCustomerInfo(info);
      return _status.isPremium;
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        // User dismissed the sheet — not an error from our side.
        return false;
      }
      debugPrint('[AURA] purchasePremium error: $code');
      return false;
    }
  }

  @override
  Future<bool> restorePurchases() async {
    try {
      final info = await Purchases.restorePurchases();
      _onCustomerInfo(info);
      return _status.isPremium;
    } on Object catch (e) {
      debugPrint('[AURA] restorePurchases error: $e');
      return false;
    }
  }

  void dispose() {
    Purchases.removeCustomerInfoUpdateListener(_onCustomerInfo);
    _controller.close();
  }
}
