import 'package:flutter/material.dart';

/// Tema sobrio inspirado en Notion, Linear y Obsidian.
abstract class AppTheme {
  static const accent = Color(0xFF5E6AD2);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
    ).copyWith(
      primary: isDark ? const Color(0xFF8B95E8) : accent,
      surface: isDark ? const Color(0xFF161618) : Colors.white,
      surfaceContainerLowest:
          isDark ? const Color(0xFF0F0F11) : const Color(0xFFFAFAF8),
      surfaceContainerLow:
          isDark ? const Color(0xFF1A1A1D) : const Color(0xFFF4F4F2),
      surfaceContainer:
          isDark ? const Color(0xFF1E1E22) : const Color(0xFFEFEFED),
      outlineVariant:
          isDark ? const Color(0xFF2A2A2E) : const Color(0xFFE6E6E3),
    );

    final baseText = Typography.material2021(platform: TargetPlatform.macOS)
        .englishLike
        .apply(
          bodyColor: isDark ? const Color(0xFFE8E8E6) : const Color(0xFF27272A),
          displayColor:
              isDark ? const Color(0xFFF2F2F0) : const Color(0xFF18181B),
        );

    final radius = BorderRadius.circular(10);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surfaceContainerLowest,
      textTheme: baseText,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.comfortable,
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surfaceContainerLowest,
        foregroundColor: baseText.titleLarge?.color,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: baseText.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        hoverColor: Colors.transparent,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
        hintStyle: TextStyle(
          color: isDark ? const Color(0xFF6E6E76) : const Color(0xFFA1A1AA),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: radius),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: radius),
          side: BorderSide(color: scheme.outlineVariant),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: baseText.labelMedium,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2E) : const Color(0xFF27272A),
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: scheme.primary,
        unselectedLabelColor:
            isDark ? const Color(0xFF8E8E96) : const Color(0xFF71717A),
        indicatorColor: scheme.primary,
        dividerColor: scheme.outlineVariant,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(
          isDark ? const Color(0xFF3A3A3F) : const Color(0xFFD4D4D1),
        ),
        radius: const Radius.circular(8),
      ),
    );
  }
}
