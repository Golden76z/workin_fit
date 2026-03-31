/// Semantic opacity constants used throughout the app.
///
/// Instead of scattering inline alpha literals like `.withValues(alpha: 0.15)`
/// across widgets, reference a named constant here so every screen stays
/// visually consistent and future tweaks happen in one place.
class AppOpacity {
  AppOpacity._();

  // ── Tier 1 — barely-there (backgrounds, shadows, glows) ──────────────────

  /// 5 % — hairline shadows (2 usages)
  static const double hairline = 0.05;

  /// 6 % — minimal shadows / box decoration (4 usages)
  static const double trace = 0.06;

  /// 8 % — light container / card backgrounds (14 usages)
  static const double faint = 0.08;

  /// 10 % — very soft borders, field fills (16 usages)
  static const double whisper = 0.10;

  /// 12 % — dividers, ghost borders (15 usages)
  static const double subtle = 0.12;

  /// 15 % — chip / badge / pill backgrounds (25 usages)
  static const double light = 0.15;

  // ── Tier 2 — low-medium (overlays, selections, cards) ─────────────────────

  /// 18 % — soft card tints, inner highlights (10 usages)
  static const double muted = 0.18;

  /// 20 % — overlays, stat pills, soft badges (18 usages)
  static const double soft = 0.20;

  /// 25 % — visible borders, chip outlines (13 usages)
  static const double medium = 0.25;

  /// 28 % — mid borders, inner ring accents (6 usages)
  static const double thin = 0.28;

  /// 30 % — emphasis borders, shadow rings (23 usages)
  static const double mild = 0.30;

  /// 35 % — stronger shadow / border accents (19 usages)
  static const double moderate = 0.35;

  /// 40 % — solid chip borders, darker shadows (22 usages)
  static const double firm = 0.40;

  /// 45 % — button-level overlay, mid-state tints (10 usages)
  static const double dim = 0.45;

  // ── Tier 3 — medium-high (icons, labels, foreground) ──────────────────────

  /// 50 % — mid overlays, disabled states (33 usages)
  static const double half = 0.50;

  /// 55 % — secondary icon tints, muted text (12 usages)
  static const double over = 0.55;

  /// 60 % — icons and text in empty states (26 usages)
  static const double visible = 0.60;

  /// 70 % — nav bar / top surface tint — matches 0xB3 alpha (23 usages)
  static const double prominent = 0.70;

  /// 75 % — nearly-opaque text and icons (6 usages)
  static const double strong = 0.75;

  /// 80 % — captions, secondary labels (14 usages)
  static const double bold = 0.80;

  /// 82 % — large greeting / hero text (1 usage)
  static const double high = 0.82;
}
