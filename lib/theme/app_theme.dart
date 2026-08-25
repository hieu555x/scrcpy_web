import 'package:flutter/material.dart';

/// Bộ token thiết kế "Bàn điều khiển".
///
/// Nền graphite tối (dark-first) với accent xanh bạc hà chỉ dùng cho
/// những gì đang *sống*: thiết bị đã kết nối, hành động chính.
/// Thông số kỹ thuật dùng JetBrains Mono để tách khỏi văn bản thường.
abstract final class AppColors {
  // --- Dark (mặc định) ---
  static const bg = Color(0xFF0F1211);
  static const surface = Color(0xFF161B19);
  static const surfaceHigh = Color(0xFF1D2421);
  static const border = Color(0xFF29332E);
  static const borderStrong = Color(0xFF364139);

  // --- Light ---
  static const bgLight = Color(0xFFF1F4F0);
  static const surfaceLight = Color(0xFFFCFDFC);
  static const surfaceHighLight = Color(0xFFEDF1EC);
  static const borderLight = Color(0xFFDDE4DD);

  // --- Chữ ---
  static const textHigh = Color(0xFFEAEEEB);
  static const textMid = Color(0xFF9BA59E);
  static const textLow = Color(0xFF67716A);
  static const textHighLight = Color(0xFF18201B);
  static const textMidLight = Color(0xFF5C665F);

  // --- Accent "tín hiệu" ---
  static const mint = Color(0xFF3FD68F);
  static const mintDeep = Color(0xFF12A463);
  static const amber = Color(0xFFE8B44A);
  static const coral = Color(0xFFF0716C);

  /// Màu trạng thái kết nối, dùng chung mọi nơi (tab, status, dock).
  static Color stateColor(bool isDark, String state) {
    switch (state) {
      case 'connected':
        return isDark ? mint : mintDeep;
      case 'connecting':
        return amber;
      case 'error':
        return coral;
      default:
        return isDark ? textLow : textMidLight;
    }
  }
}

/// Các font family đã khai báo trong pubspec.yaml.
abstract final class AppFonts {
  static const display = 'SpaceGrotesk';
  static const body = 'Inter';
  static const mono = 'JetBrainsMono';
}

ThemeData buildAppTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;

  final scheme = ColorScheme(
    brightness: brightness,
    primary: isDark ? AppColors.mint : AppColors.mintDeep,
    onPrimary: isDark ? const Color(0xFF06231A) : Colors.white,
    primaryContainer: isDark ? AppColors.surfaceHigh : AppColors.surfaceHighLight,
    onPrimaryContainer: isDark ? AppColors.mint : AppColors.mintDeep,
    secondary: isDark ? AppColors.surfaceHigh : AppColors.surfaceHighLight,
    onSecondary: isDark ? AppColors.textHigh : AppColors.textHighLight,
    secondaryContainer: isDark ? AppColors.surfaceHigh : AppColors.surfaceHighLight,
    onSecondaryContainer: isDark ? AppColors.textMid : AppColors.textMidLight,
    tertiary: isDark ? AppColors.amber : AppColors.amber,
    onTertiary: const Color(0xFF241B05),
    error: AppColors.coral,
    onError: isDark ? const Color(0xFF2A0806) : Colors.white,
    surface: isDark ? AppColors.bg : AppColors.bgLight,
    onSurface: isDark ? AppColors.textHigh : AppColors.textHighLight,
    surfaceContainerLowest: isDark ? AppColors.bg : AppColors.bgLight,
    surfaceContainerLow: isDark ? AppColors.bg : AppColors.bgLight,
    surfaceContainer: isDark ? AppColors.surface : AppColors.surfaceLight,
    surfaceContainerHigh: isDark ? AppColors.surfaceHigh : AppColors.surfaceHighLight,
    surfaceContainerHighest:
        isDark ? AppColors.surfaceHigh : AppColors.surfaceHighLight,
    onSurfaceVariant: isDark ? AppColors.textMid : AppColors.textMidLight,
    outline: isDark ? AppColors.borderStrong : AppColors.borderLight,
    outlineVariant: isDark ? AppColors.border : AppColors.borderLight,
    shadow: Colors.black,
    scrim: Colors.black54,
    inverseSurface: isDark ? AppColors.surfaceLight : AppColors.bg,
    onInverseSurface: isDark ? AppColors.textHighLight : AppColors.textHigh,
    inversePrimary: isDark ? AppColors.mintDeep : AppColors.mint,
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    brightness: brightness,
    scaffoldBackgroundColor: scheme.surfaceContainerLowest,
    splashFactory: InkSparkle.splashFactory,
  );

  final monoStyle = TextStyle(fontFamily: AppFonts.mono, fontSize: 11);

  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      displaySmall: base.textTheme.displaySmall?.copyWith(
        fontFamily: AppFonts.display,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        height: 1.15,
      ),
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontFamily: AppFonts.display,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelSmall: monoStyle.copyWith(
        letterSpacing: 0.8,
        height: 1.2,
        color: scheme.onSurfaceVariant,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: AppFonts.display,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: scheme.onSurface,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant,
      thickness: 1,
      space: 1,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? scheme.onPrimary
            : (isDark ? AppColors.textLow : AppColors.textMidLight),
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? scheme.primary
            : (isDark ? AppColors.surfaceHigh : AppColors.borderLight),
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? Colors.transparent
            : scheme.outlineVariant,
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: scheme.primary,
      inactiveTrackColor: isDark ? AppColors.surfaceHigh : AppColors.borderLight,
      thumbColor: scheme.primary,
      overlayColor: scheme.primary.withAlpha(40),
      trackHeight: 3,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(
          isDark ? AppColors.surfaceHigh : AppColors.surfaceLight,
        ),
        elevation: const WidgetStatePropertyAll(8),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 6),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? AppColors.surface : AppColors.surfaceLight,
      hintStyle: TextStyle(color: scheme.onSurfaceVariant.withAlpha(120)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceHigh : AppColors.textHighLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      textStyle: TextStyle(
        fontFamily: AppFonts.body,
        fontSize: 12,
        color: isDark ? AppColors.textHigh : AppColors.bgLight,
      ),
      waitDuration: const Duration(milliseconds: 400),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: isDark ? AppColors.surfaceHigh : AppColors.textHighLight,
      contentTextStyle: TextStyle(color: scheme.onSurface, fontSize: 13),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: scheme.primary,
      linearTrackColor: scheme.outlineVariant,
    ),
  );
}
