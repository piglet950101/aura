/// 4-pt spacing scale. Use these everywhere — no raw numbers in widgets.
abstract final class AuraSpacing {
  AuraSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Minimum tap target across the app.
  /// Above Material's 48dp recommendation by design — the brief calls for
  /// "alvos de toque grandes (mãos que tremem)" during a crisis.
  static const double tapTargetMin = 56;
}
