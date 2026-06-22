import 'package:flutter/material.dart';

import 'cairn_colors.dart';

/// Two voices, kept minimal (Style Tile §02):
///  • **Hanken Grotesk** — interface & numbers. Shipped as a single *variable*
///    font, so weights are applied via `FontVariation('wght', n)` rather than
///    relying on the renderer to pick an instance.
///  • **Space Mono** — labels & trust tags. Small, uppercase, tracked.
abstract final class CairnType {
  CairnType._();

  static const String interfaceFamily = 'Hanken Grotesk';
  static const String monoFamily = 'Space Mono';

  /// Numeric weight axis value for a [FontWeight] (w400 → 400, w600 → 600 …).
  static double _wght(FontWeight w) => w.value.toDouble();

  /// An interface (Hanken Grotesk) style with the weight applied to the
  /// variable-font `wght` axis.
  static TextStyle interface(
    double size,
    FontWeight weight, {
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: interfaceFamily,
      fontSize: size,
      fontWeight: weight,
      fontVariations: [FontVariation('wght', _wght(weight))],
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// A Space Mono style. [letterSpacing] is absolute (logical px); the design's
  /// em tracking is pre-converted in the named tokens below.
  static TextStyle mono(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontFamily: monoFamily,
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // ── Named mono tokens (uppercase, tracked) ─────────────────────────────
  /// Trust/accent tag, e.g. "ON-DEVICE ONLY". 13 / .18em.
  static TextStyle get monoTag =>
      mono(13, color: CairnColors.sage, letterSpacing: 2.3);

  /// Quiet meta label, e.g. "LIFETIME · 47 DAYS". 13 / .18em.
  static TextStyle get monoMeta =>
      mono(13, color: CairnColors.textDim, letterSpacing: 2.3);

  /// Small section/caption label. 11 / .15em.
  static TextStyle get monoLabel =>
      mono(11, color: CairnColors.textMuted, letterSpacing: 1.7);

  /// The standard interface button label (15 / 600). Colour comes from the
  /// button theme.
  static TextStyle get button => interface(15, FontWeight.w600);

  /// Builds the Material [TextTheme] for a given ink pair.
  static TextTheme textTheme({required Color hi, required Color dim}) {
    return TextTheme(
      // "Day 14" hero number.
      displayLarge:
          interface(48, FontWeight.w600, color: hi, height: 1, letterSpacing: -0.96),
      displayMedium:
          interface(36, FontWeight.w600, color: hi, height: 1, letterSpacing: -0.72),
      displaySmall: interface(30, FontWeight.w600, color: hi, height: 1.05),
      // "Still clean" title.
      headlineMedium: interface(28, FontWeight.w600, color: hi, letterSpacing: -0.28),
      titleLarge: interface(28, FontWeight.w600, color: hi, letterSpacing: -0.28),
      // "Your trail so far" heading.
      titleMedium: interface(18, FontWeight.w600, color: hi),
      titleSmall: interface(16, FontWeight.w600, color: hi),
      // Body copy.
      bodyLarge: interface(15, FontWeight.w400, color: dim, height: 1.5),
      bodyMedium: interface(14, FontWeight.w400, color: dim, height: 1.45),
      bodySmall: interface(13, FontWeight.w400, color: dim, height: 1.5),
      // Buttons use labelLarge; mono drives the small tracked labels.
      labelLarge: interface(15, FontWeight.w600, color: hi),
      labelMedium: mono(13, color: dim, letterSpacing: 2.3),
      labelSmall: mono(11, color: CairnColors.textMuted, letterSpacing: 1.7),
    );
  }
}
