import 'package:flutter/material.dart';

/// Cairn brand colour tokens — dark-first and earthy.
///
/// Extracted verbatim from the "Cairn Style Tile" design composition.
/// Rules from the brief: no red, no alarm states; the earthy tones *are* the
/// metaphor; **sage is the only saturated accent**, used one-thing-at-a-time.
abstract final class CairnColors {
  CairnColors._();

  // ── Canvas & surfaces (dark) ───────────────────────────────────────────
  static const Color canvas = Color(0xFF181D18);
  static const Color surface = Color(0xFF232A24);
  static const Color raised = Color(0xFF2C342D);

  /// Muted stage behind the mascot art (slightly off-canvas).
  static const Color cairnStage = Color(0xFF1F261F);

  // ── Text ───────────────────────────────────────────────────────────────
  static const Color textHi = Color(0xFFECE7DB);
  static const Color textDim = Color(0xFFA7A99B);

  /// Tertiary / mono labels / timestamps.
  static const Color textMuted = Color(0xFF6E7468);

  /// Soft greenish-grey for inline status ("still clean") and hero subtext.
  static const Color textSubtle = Color(0xFF7F857A);

  /// Faintest green-grey for footer whispers.
  static const Color textFaint = Color(0xFF525A4F);

  /// Bottom-nav surface (sits between canvas and surface).
  static const Color navBar = Color(0xFF1B211C);

  // ── Stones (the streak visual) ─────────────────────────────────────────
  static const Color stoneSand = Color(0xFFB19C7D);
  static const Color stoneGrey = Color(0xFFA59F93);
  static const Color stoneSage = Color(0xFF9EA28B);

  // ── Accent — the single saturated colour ───────────────────────────────
  static const Color sage = Color(0xFFAAB68F);

  /// Ink/icon colour on a sage fill.
  static const Color onSage = Color(0xFF1B201B);

  // ── Hairlines / borders (warm white at low alpha) ──────────────────────
  static const Color border = Color(0x1AECE7DB); // .10
  static const Color borderSoft = Color(0x0FECE7DB); // .06
  static const Color borderStrong = Color(0x38ECE7DB); // .22 — outline buttons

  /// Selection / focus wash.
  static const Color sageWash = Color(0x4DAAB68F); // .30

  // ── Light mode (polished secondary) ────────────────────────────────────
  // The dark palette is the brand; light keeps the earthy character while
  // flipping canvas/ink. Design owns exact light values later.
  static const Color lightCanvas = Color(0xFFF2EEE4);
  static const Color lightSurface = Color(0xFFFBF8F1);
  static const Color lightRaised = Color(0xFFFFFFFF);
  static const Color lightTextHi = Color(0xFF20251F);
  static const Color lightTextDim = Color(0xFF565B4F);
  static const Color lightTextMuted = Color(0xFF808475);

  /// Darker sage so accent text/borders meet contrast on a light canvas.
  static const Color lightSage = Color(0xFF6E7C50);
  static const Color lightBorder = Color(0x14202520); // ~.08 dark ink
  static const Color lightBorderStrong = Color(0x33202520);
}
