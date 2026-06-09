import 'package:aura/data/auth/auth_repository_provider.dart';
import 'package:aura/data/entitlement/mock_entitlement_service.dart';
import 'package:aura/data/entitlement/revenuecat_entitlement_service.dart';
import 'package:aura/domain/entitlement/entitlement.dart';
import 'package:aura/domain/entitlement/entitlement_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kRcAndroidKey = String.fromEnvironment('RC_ANDROID_KEY');
const _kRcIosKey = String.fromEnvironment('RC_IOS_KEY');
const _kRcEntitlementId = String.fromEnvironment('RC_ENTITLEMENT_ID', defaultValue: 'premium');
const _kRcOfferingId = String.fromEnvironment('RC_OFFERING_ID');
const _kForcePremium = bool.fromEnvironment('AURA_FORCE_PREMIUM');

/// Selects the right [EntitlementService] for the current build:
///   - If RevenueCat keys are configured AND there's a user, use the real
///     impl. The bootstrap layer is responsible for calling `init()` on it
///     once Supabase has resolved the current user — see the
///     `entitlementInitProvider` future below.
///   - Otherwise (theme-preview build, dev with no env, widget tests) use
///     the mock. `AURA_FORCE_PREMIUM=true` flips the mock to premium for
///     QA shortcuts without paying.
///
/// Override this in `ProviderScope` for tests that need a custom impl.
final entitlementServiceProvider = Provider<EntitlementService>((ref) {
  if (_kRcAndroidKey.isEmpty && _kRcIosKey.isEmpty) {
    // `_kForcePremium` is a build-time define; in a dev build it's false
    // (and the analyzer sees that), but QA can build with
    // `--dart-define=AURA_FORCE_PREMIUM=true` to bypass the paywall, which
    // would change the argument value at compile time.
    // ignore: avoid_redundant_argument_values
    final mock = MockEntitlementService(startPremium: _kForcePremium);
    ref.onDispose(mock.dispose);
    return mock;
  }
  final user = ref.watch(authRepositoryProvider).currentUser;
  final svc = RevenueCatEntitlementService(
    androidApiKey: _kRcAndroidKey,
    iosApiKey: _kRcIosKey,
    entitlementId: _kRcEntitlementId,
    offeringId: _kRcOfferingId.isEmpty ? null : _kRcOfferingId,
    appUserId: user?.id,
  );
  ref.onDispose(svc.dispose);
  return svc;
});

/// Fires the SDK init exactly once. Watch this in `bootstrap.dart` after
/// Supabase auth resolves so the customer is correctly aliased.
final entitlementInitProvider = FutureProvider<void>((ref) async {
  final svc = ref.watch(entitlementServiceProvider);
  if (svc is RevenueCatEntitlementService) {
    await svc.init();
  }
});

/// Stream of the user's current entitlement state — what screens watch.
/// First emission is the synchronous `current` snapshot so widgets don't
/// flash "loading" on the gates.
final entitlementStatusProvider = StreamProvider<EntitlementStatus>((ref) {
  final svc = ref.watch(entitlementServiceProvider);
  return svc.watch();
});
