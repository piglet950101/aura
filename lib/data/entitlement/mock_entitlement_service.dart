import 'dart:async';

import 'package:aura/domain/entitlement/entitlement.dart';
import 'package:aura/domain/entitlement/entitlement_service.dart';

/// In-memory entitlement service for development, widget tests, and the
/// theme-preview build. Defaults to "free" so the paywall is reachable; a
/// dart-define (`AURA_FORCE_PREMIUM=1`) flips that for QA shortcuts.
///
/// The production binary uses `RevenueCatEntitlementService`; the mock is
/// selected by the provider only when no RevenueCat API key is configured
/// (env file missing or empty key), so the prod APK can't accidentally ship
/// with a permanently-premium user.
class MockEntitlementService implements EntitlementService {
  MockEntitlementService({bool startPremium = false})
    : _status = EntitlementStatus(
        isPremium: startPremium,
        source: startPremium ? 'mock-premium' : 'mock-free',
      ) {
    _controller.add(_status);
  }

  final _controller = StreamController<EntitlementStatus>.broadcast();
  EntitlementStatus _status;

  @override
  EntitlementStatus get current => _status;

  @override
  Stream<EntitlementStatus> watch() async* {
    yield _status;
    yield* _controller.stream;
  }

  @override
  Future<bool> purchasePremium() async {
    _status = const EntitlementStatus(isPremium: true, source: 'mock-premium');
    _controller.add(_status);
    return true;
  }

  @override
  Future<bool> restorePurchases() async {
    // No previous purchases in mock mode — restore is a no-op.
    return _status.isPremium;
  }

  /// Test hook — flip back to free without restarting the process.
  void resetToFree() {
    _status = const EntitlementStatus(isPremium: false, source: 'mock-free');
    _controller.add(_status);
  }

  void dispose() {
    _controller.close();
  }
}
