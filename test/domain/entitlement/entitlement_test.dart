import 'package:aura/data/entitlement/mock_entitlement_service.dart';
import 'package:aura/domain/entitlement/entitlement.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EntitlementStatus', () {
    test('free user is blocked from premium features', () {
      const free = EntitlementStatus(isPremium: false, source: 'mock-free');
      expect(free.allows(PremiumFeature.reportExport), isFalse);
      expect(free.allows(PremiumFeature.extendedStats), isFalse);
    });

    test('premium user passes every feature gate', () {
      const premium = EntitlementStatus(isPremium: true, source: 'rc-active');
      for (final f in PremiumFeature.values) {
        expect(premium.allows(f), isTrue, reason: 'premium must unlock $f');
      }
    });

    test('default .free() is non-premium', () {
      const pending = EntitlementStatus.free();
      expect(pending.isPremium, isFalse);
      expect(pending.source, 'pending');
    });
  });

  group('MockEntitlementService', () {
    test('starts free by default and flips to premium on purchase', () async {
      final svc = MockEntitlementService();
      addTearDown(svc.dispose);
      expect(svc.current.isPremium, isFalse);

      final ok = await svc.purchasePremium();
      expect(ok, isTrue);
      expect(svc.current.isPremium, isTrue);
    });

    test('emits the current value on first listen', () async {
      final svc = MockEntitlementService();
      addTearDown(svc.dispose);
      final first = await svc.watch().first;
      expect(first.isPremium, isFalse);
    });

    test('emits a new value after a purchase', () async {
      final svc = MockEntitlementService();
      addTearDown(svc.dispose);
      final values = <bool>[];
      final sub = svc.watch().listen((s) => values.add(s.isPremium));
      await svc.purchasePremium();
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      expect(values, contains(true));
    });

    test('AURA_FORCE_PREMIUM seeds premium for QA shortcuts', () {
      final svc = MockEntitlementService(startPremium: true);
      addTearDown(svc.dispose);
      expect(svc.current.isPremium, isTrue);
      expect(svc.current.source, 'mock-premium');
    });

    test('restore on a never-purchased mock is a no-op', () async {
      final svc = MockEntitlementService();
      addTearDown(svc.dispose);
      final ok = await svc.restorePurchases();
      expect(ok, isFalse);
    });

    test('resetToFree flips premium back', () async {
      final svc = MockEntitlementService(startPremium: true);
      addTearDown(svc.dispose);
      expect(svc.current.isPremium, isTrue);
      svc.resetToFree();
      expect(svc.current.isPremium, isFalse);
    });
  });
}
