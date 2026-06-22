import 'package:flutter/material.dart';

import 'cairn_colors.dart';
import 'cairn_dimens.dart';
import 'cairn_typography.dart';

/// The Cairn [ThemeData]. Dark is the brand surface; light is the polished
/// secondary. Built entirely from the Style Tile tokens — one sage primary
/// action per screen, everything else quiet, no alarm colours.
abstract final class CairnTheme {
  CairnTheme._();

  static ThemeData dark() => _build(_darkScheme, hi: CairnColors.textHi, dim: CairnColors.textDim);

  static ThemeData light() =>
      _build(_lightScheme, hi: CairnColors.lightTextHi, dim: CairnColors.lightTextDim);

  // ── Colour schemes ──────────────────────────────────────────────────────
  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: CairnColors.sage,
    onPrimary: CairnColors.onSage,
    primaryContainer: CairnColors.raised,
    onPrimaryContainer: CairnColors.textHi,
    secondary: CairnColors.stoneSage,
    onSecondary: CairnColors.onSage,
    secondaryContainer: CairnColors.surface,
    onSecondaryContainer: CairnColors.textHi,
    tertiary: CairnColors.stoneSand,
    onTertiary: CairnColors.onSage,
    // No alarm-red in the brand; "error" maps to a muted sand and is never
    // used as a fear state in the UI.
    error: CairnColors.stoneSand,
    onError: CairnColors.onSage,
    surface: CairnColors.canvas,
    onSurface: CairnColors.textHi,
    onSurfaceVariant: CairnColors.textDim,
    surfaceContainerLowest: CairnColors.canvas,
    surfaceContainerLow: CairnColors.surface,
    surfaceContainer: CairnColors.surface,
    surfaceContainerHigh: CairnColors.raised,
    surfaceContainerHighest: CairnColors.raised,
    outline: CairnColors.borderStrong,
    outlineVariant: CairnColors.border,
    shadow: Color(0xFF000000),
    scrim: Color(0xCC000000),
    inverseSurface: CairnColors.textHi,
    onInverseSurface: CairnColors.canvas,
    inversePrimary: CairnColors.sage,
  );

  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: CairnColors.lightSage,
    onPrimary: Color(0xFFFBF8F1),
    primaryContainer: Color(0xFFE6E7D6),
    onPrimaryContainer: CairnColors.lightTextHi,
    secondary: CairnColors.stoneSage,
    onSecondary: Color(0xFFFBF8F1),
    secondaryContainer: Color(0xFFEDEAE0),
    onSecondaryContainer: CairnColors.lightTextHi,
    tertiary: CairnColors.stoneSand,
    onTertiary: Color(0xFFFBF8F1),
    error: CairnColors.stoneSand,
    onError: Color(0xFFFBF8F1),
    surface: CairnColors.lightCanvas,
    onSurface: CairnColors.lightTextHi,
    onSurfaceVariant: CairnColors.lightTextDim,
    surfaceContainerLowest: CairnColors.lightRaised,
    surfaceContainerLow: CairnColors.lightSurface,
    surfaceContainer: CairnColors.lightSurface,
    surfaceContainerHigh: Color(0xFFEEEAE0),
    surfaceContainerHighest: Color(0xFFE8E4D8),
    outline: CairnColors.lightBorderStrong,
    outlineVariant: CairnColors.lightBorder,
    shadow: Color(0xFF000000),
    scrim: Color(0x66000000),
    inverseSurface: CairnColors.lightTextHi,
    onInverseSurface: CairnColors.lightCanvas,
    inversePrimary: CairnColors.lightSage,
  );

  // ── Builder ─────────────────────────────────────────────────────────────
  static ThemeData _build(ColorScheme scheme, {required Color hi, required Color dim}) {
    final text = CairnType.textTheme(hi: hi, dim: dim);
    final isDark = scheme.brightness == Brightness.dark;

    OutlinedBorder rounded(double r) =>
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(r));

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      fontFamily: CairnType.interfaceFamily,
      textTheme: text,
      primaryTextTheme: text,
      splashFactory: InkSparkle.splashFactory,
      iconTheme: IconThemeData(color: dim),
      primaryIconTheme: IconThemeData(color: hi),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        foregroundColor: hi,
        titleTextStyle: text.titleMedium,
        iconTheme: IconThemeData(color: hi),
      ),
      // Primary: the one sage action per screen.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.primary.withValues(alpha: 0.35),
          disabledForegroundColor: scheme.onPrimary.withValues(alpha: 0.6),
          textStyle: CairnType.button,
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
          shape: rounded(CairnRadii.md),
          elevation: 0,
          minimumSize: const Size(0, 50),
        ),
      ),
      // Secondary: quiet outline.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: hi,
          textStyle: CairnType.button,
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
          side: BorderSide(color: scheme.outline),
          shape: rounded(CairnRadii.md),
          minimumSize: const Size(0, 50),
        ),
      ),
      // Tertiary: text only (e.g. "Open anyway" — never hidden).
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: CairnType.button,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        selectedColor: scheme.primary,
        disabledColor: scheme.surfaceContainerHigh,
        side: BorderSide(color: scheme.outlineVariant),
        shape: const StadiumBorder(),
        labelStyle: CairnType.interface(13, FontWeight.w500, color: hi),
        secondaryLabelStyle: CairnType.interface(13, FontWeight.w500, color: scheme.onPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        showCheckmark: false,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CairnRadii.lg),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: rounded(CairnRadii.xl),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyLarge,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: scheme.outline,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(CairnRadii.xl)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        contentTextStyle: text.bodyMedium?.copyWith(color: hi),
        actionTextColor: scheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: rounded(CairnRadii.md),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? scheme.onPrimary : dim,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? scheme.primary : scheme.surfaceContainerHighest,
        ),
        trackOutlineColor: WidgetStateProperty.all(scheme.outlineVariant),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHigh,
        circularTrackColor: scheme.surfaceContainerHigh,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: dim,
        textColor: hi,
        titleTextStyle: text.titleSmall,
        subtitleTextStyle: text.bodySmall,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: scheme.primary,
        selectionColor: CairnColors.sageWash,
        selectionHandleColor: scheme.primary,
      ),
      splashColor: CairnColors.sageWash.withValues(alpha: isDark ? 0.12 : 0.18),
      highlightColor: Colors.transparent,
    );
  }
}
