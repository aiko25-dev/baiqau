import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_styles.dart';

export 'app_colors.dart';
export 'app_styles.dart';

ThemeData buildTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.primary,
        onPrimary: AppColors.surface,
        primaryContainer: AppColors.softPurple,
        onPrimaryContainer: AppColors.primaryStrong,
        secondary: AppColors.primaryLight,
        onSecondary: AppColors.textPrimary,
        secondaryContainer: AppColors.softPurple,
        onSecondaryContainer: AppColors.primaryStrong,
        tertiary: AppColors.successInk,
        tertiaryContainer: AppColors.successSurface,
        onTertiaryContainer: AppColors.successInk,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        onSurfaceVariant: AppColors.textSecondary,
        surfaceContainerLowest: AppColors.surface,
        surfaceContainerLow: AppColors.background,
        surfaceContainer: AppColors.softPurple,
        surfaceContainerHigh: AppColors.softPurple,
        surfaceContainerHighest: AppColors.border,
        outline: AppColors.textSecondary,
        outlineVariant: AppColors.border,
        error: AppColors.error,
        onError: AppColors.surface,
        errorContainer: AppColors.errorSurface,
        onErrorContainer: AppColors.error,
        surfaceTint: Colors.transparent,
      );
  const textTheme = TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      height: 1.22,
      letterSpacing: -.9,
      color: AppColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w600,
      height: 1.3,
      letterSpacing: -.6,
      color: AppColors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.35,
      letterSpacing: -.35,
      color: AppColors.textPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: AppColors.textPrimary,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: AppColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 15,
      height: 1.65,
      color: AppColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      height: 1.55,
      color: AppColors.textPrimary,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      height: 1.5,
      color: AppColors.textSecondary,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      height: 1.4,
    ),
  );
  final fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppStyles.controlRadius),
    borderSide: const BorderSide(color: AppColors.border),
  );
  final controlShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppStyles.controlRadius),
  );
  return ThemeData(
    fontFamily: 'Manrope',
    fontFamilyFallback: AppStyles.fontFallback,
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: textTheme,
    iconTheme: const IconThemeData(color: AppColors.primaryStrong, size: 22),
    disabledColor: AppColors.textSecondary.withValues(alpha: .45),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      toolbarHeight: 64,
      titleTextStyle: TextStyle(
        fontFamily: 'Manrope',
        fontFamilyFallback: AppStyles.fontFallback,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      iconTheme: IconThemeData(color: AppColors.primaryStrong),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shadowColor: AppColors.primaryStrong.withValues(alpha: .10),
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.cardRadius),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      alignLabelWithHint: true,
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      floatingLabelStyle: const TextStyle(color: AppColors.primaryStrong),
      errorStyle: const TextStyle(color: AppColors.error, height: 1.4),
      prefixIconColor: AppColors.primaryStrong,
      suffixIconColor: AppColors.textSecondary,
      border: fieldBorder,
      enabledBorder: fieldBorder,
      disabledBorder: fieldBorder,
      focusedBorder: fieldBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.6),
      ),
      errorBorder: fieldBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: fieldBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.error, width: 1.6),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primaryAction,
        foregroundColor: AppColors.surface,
        disabledBackgroundColor: AppColors.border,
        disabledForegroundColor: AppColors.textSecondary,
        minimumSize: const Size(0, 54),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        shape: controlShape,
        textStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontFamilyFallback: AppStyles.fontFallback,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.softPurple,
        foregroundColor: AppColors.primaryStrong,
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        side: const BorderSide(color: AppColors.border),
        shape: controlShape,
        textStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontFamilyFallback: AppStyles.fontFallback,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryStrong,
        minimumSize: const Size(48, 48),
        shape: controlShape,
        textStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontFamilyFallback: AppStyles.fontFallback,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.softPurple,
      disabledColor: AppColors.background,
      checkmarkColor: AppColors.primaryStrong,
      labelStyle: const TextStyle(
        fontFamily: 'Manrope',
        fontFamilyFallback: AppStyles.fontFallback,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryStrong,
      ),
      side: const BorderSide(color: AppColors.border),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      indicatorColor: AppColors.softPurple,
      indicatorShape: const StadiumBorder(),
      height: 76,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 23,
          color: states.contains(WidgetState.selected)
              ? AppColors.primaryStrong
              : AppColors.textSecondary,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontFamily: 'Manrope',
          fontFamilyFallback: AppStyles.fontFallback,
          fontSize: 10,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.w500,
          color: states.contains(WidgetState.selected)
              ? AppColors.primaryStrong
              : AppColors.textSecondary,
        ),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.primaryStrong,
      textColor: AppColors.textPrimary,
      titleTextStyle: TextStyle(
        fontFamily: 'Manrope',
        fontFamilyFallback: AppStyles.fontFallback,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.45,
        color: AppColors.textPrimary,
      ),
      subtitleTextStyle: TextStyle(
        fontFamily: 'Manrope',
        fontFamilyFallback: AppStyles.fontFallback,
        fontSize: 12,
        height: 1.5,
        color: AppColors.textSecondary,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      titleTextStyle: textTheme.titleLarge?.copyWith(
        fontFamily: 'Manrope',
        fontFamilyFallback: AppStyles.fontFallback,
      ),
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        fontFamily: 'Manrope',
        fontFamilyFallback: AppStyles.fontFallback,
      ),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      headerBackgroundColor: AppColors.softPurple,
      headerForegroundColor: AppColors.primaryStrong,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: const WidgetStatePropertyAll(AppColors.surface),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: AppColors.primaryLight,
      inactiveTrackColor: AppColors.softPurple,
      thumbColor: AppColors.primary,
      overlayColor: Color(0x168B5CF6),
      valueIndicatorColor: AppColors.primaryStrong,
      trackHeight: 5,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.softPurple,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.primaryStrong,
      selectionColor: AppColors.accent.withValues(alpha: .4),
      selectionHandleColor: AppColors.primary,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.softPurple,
      contentTextStyle: const TextStyle(
        fontFamily: 'Manrope',
        fontFamilyFallback: AppStyles.fontFallback,
        fontSize: 14,
        color: AppColors.primaryStrong,
      ),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: .8,
    ),
  );
}
