import 'package:aura/domain/entitlement/entitlement.dart';

/// Resolves and streams the user's premium entitlement state. The interface
/// is provider-agnostic so the rest of the app never imports
/// `purchases_flutter`; swapping RevenueCat for another store is one impl
/// swap, not a refactor.
///
/// Implementations:
///   - `MockEntitlementService`: in-memory toggle for dev + tests
///   - `RevenueCatEntitlementService`: real production wiring (lib/data/...)
abstract class EntitlementService {
  /// Live stream of entitlement state. Emits the current value on subscribe
  /// and every change after that. Used by screens to react to a successful
  /// purchase or to a "restore purchases" flow completing.
  Stream<EntitlementStatus> watch();

  /// Current snapshot — useful for one-shot checks that don't want to
  /// listen (e.g. wrapping a callback at tap time).
  EntitlementStatus get current;

  /// Trigger the purchase flow for the monthly premium subscription.
  /// Returns true if the user ended up entitled (purchased now or already).
  /// Does not throw on user cancel — returns false.
  Future<bool> purchasePremium();

  /// Re-query the provider for previous purchases (App Store / Play
  /// "Restore Purchases" button). Returns true if the user ended up
  /// entitled after the restore.
  Future<bool> restorePurchases();
}
