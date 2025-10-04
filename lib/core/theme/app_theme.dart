import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// App-wide theme that matches the dark, orange-accented look in the design.
class AppTheme {
  // Core brand colors
  static const Color primary = Color(0xFFFF6A00); 
  static const Color primaryLight = Color(0xFFFFA24A); // Vibrant orange
  static const Color bg = Color(0xFF0F0F12); // Deep charcoal
  static const Color surface = Color(0xFF151518); // Cards / surfaces
  static const Color surfaceVariant = Color(0xFF1E1E22); // Elevated surfaces
  static const Color onBg = Color(0xFFEDEDEF); // High-contrast text
  static const Color muted = Color(0xFF8D8D93); // Secondary text

  static const Color success = Color(0xFF21C55D);
  static const Color danger = Color(0xFFEF4444);

  /// Main dark theme
  static ThemeData dark() {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    );

    final scheme = baseScheme.copyWith(
      primary: primary,
      onPrimary: Colors.white,
      secondary: const Color(0xFFFFA24A),
      onSecondary: Colors.black,
      tertiary: const Color(0xFFFB7185), // soft pink accent used sparingly
      background: bg,
      onBackground: onBg,
      surface: surface,
      onSurface: onBg,
      surfaceVariant: surfaceVariant,
      outline: const Color(0xFF2A2A2E),
      error: danger,
      onError: Colors.white,
    );

    final textTheme = const TextTheme(
      displayLarge: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
      ),
      displayMedium: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: muted,
      ),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    ).apply(displayColor: onBg, bodyColor: onBg);

    final rounded24 = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      fontFamily: "LexendDeca",
      splashFactory: InkRipple.splashFactory,
      textTheme: textTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: onBg,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
      ),

      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.all(0),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        selectedColor: primary.withOpacity(0.15),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        labelStyle: textTheme.bodyMedium!,
        shape: StadiumBorder(side: BorderSide(color: scheme.outline)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: surfaceVariant,
          foregroundColor: onBg,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onBg,
          side: BorderSide(color: scheme.outline),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: onBg,
          backgroundColor: surfaceVariant,
          shape: rounded24,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        hintStyle: TextStyle(color: muted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: muted,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        showUnselectedLabels: true,
      ),

      sliderTheme: const SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: Color(0xFF2A2A2E),
        thumbColor: primary,
        overlayColor: Color(0x33FF6A00),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: StadiumBorder(),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary),

      dividerTheme: DividerThemeData(
        color: scheme.outline.withOpacity(0.6),
        thickness: 1,
        space: 24,
      ),

      listTileTheme: ListTileThemeData(
        iconColor: onBg,
        textColor: onBg,
        tileColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      extensions: const <ThemeExtension<dynamic>>[AppGradients.defaults],
    );
  }
}

/// Optional gradients used across the app. Access via
/// `Theme.of(context).extension<AppGradients>()`.
@immutable
class AppGradients extends ThemeExtension<AppGradients> {
  final Gradient accent;
  final Gradient heat;

  const AppGradients({required this.accent, required this.heat});

  static const AppGradients defaults = AppGradients(
    accent: LinearGradient(
      colors: [Color(0xFFFF6A00), Color(0xFFFF3D00)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    heat: LinearGradient(
      colors: [Color(0xFFFF6A00), Color(0xFFFFA24A)],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    ),
  );

  @override
  AppGradients copyWith({Gradient? accent, Gradient? heat}) {
    return AppGradients(accent: accent ?? this.accent, heat: heat ?? this.heat);
  }

  @override
  AppGradients lerp(ThemeExtension<AppGradients>? other, double t) {
    if (other is! AppGradients) return this;
    return this; // Gradients are not trivially lerpable; keep as-is.
  }
}
