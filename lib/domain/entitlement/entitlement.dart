/// Premium entitlement state, decoupled from the underlying provider
/// (RevenueCat today, in-house at some future date).
///
/// The freemium split for v1:
///   - `free`: basic crisis logging, calendar, medication, stats up to 90 days.
///   - `premium`: PDF report generation/share + extended stats periods
///     (6 meses + 1 ano) + HIT-6 historical trend depth.
///
/// Whether a given feature is gated is the screen's call — see
/// `EntitlementStatus.allows` for the per-feature mapping. Centralising it
/// here means the paywall, the gates, and any future "what's premium?" copy
/// stay in agreement.
enum PremiumFeature {
  /// PDF report generation + sharing (the "Relatório de Registos" flow).
  reportExport,

  /// Long-window stats periods (180d / 365d) on the Estatísticas screen.
  extendedStats,
}

/// Snapshot of the user's entitlement state. Immutable; produced by an
/// `EntitlementService` and consumed via Riverpod by screens that need to
/// gate features.
class EntitlementStatus {
  const EntitlementStatus({required this.isPremium, required this.source});

  /// "free" placeholder used before the service has resolved — equivalent
  /// to a logged-out / never-purchased state.
  const EntitlementStatus.free() : isPremium = false, source = 'pending';

  final bool isPremium;

  /// Coarse label for telemetry / debug printing only. Examples:
  ///   - `pending`: not yet resolved
  ///   - `mock-free` / `mock-premium`: dev toggle
  ///   - `rc-active` / `rc-inactive`: RevenueCat
  final String source;

  /// Single source of truth for which features the current state unlocks.
  /// Keep gating logic out of the screens — they ask `allows(feature)`.
  bool allows(PremiumFeature feature) {
    if (isPremium) return true;
    switch (feature) {
      case PremiumFeature.reportExport:
      case PremiumFeature.extendedStats:
        return false;
    }
  }
}
