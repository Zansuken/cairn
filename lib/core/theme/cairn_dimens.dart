/// Spacing and corner-radius tokens, mirroring the Style Tile.
///
/// The design breathes: gaps run 16 / 24 / 32 / 48 / 64. Radii: 14 buttons,
/// 18 cards, 24 large surfaces, 999 pills.
abstract final class CairnSpacing {
  CairnSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double huge = 64;
}

abstract final class CairnRadii {
  CairnRadii._();

  static const double sm = 10;
  static const double md = 14; // buttons & controls
  static const double lg = 18; // cards
  static const double xl = 24; // large surfaces / sheets / app icon
  static const double pill = 999;
}
