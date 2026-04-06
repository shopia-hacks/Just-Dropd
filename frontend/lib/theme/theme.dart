import 'package:flutter/material.dart';

class AppTheme {
  // ─── Brand Colors ───────────────────────────────
  static const Color green  = Color(0xFF11A253);
  static const Color blue   = Color(0xFF1660CD);
  static const Color red    = Color(0xFFF20815);
  static const Color pink   = Color(0xFFFDA5E1);
  static const Color orange = Color(0xFFFD6B04);
  static const Color yellow = Color(0xFFF9CB0A);

  static const Color white  = Colors.white;
  static const Color cream  = Color(0xFFF5F5F0);

  // ─── Color Pair Helpers ─────────────────────────
  // signature opposite-color combos
  static const List<Map<String, Color>> playfulPairs = [
    {"bg": blue,   "fg": green},   // blue bg, green text
    {"bg": red,    "fg": pink},    // red bg, pink text
    {"bg": pink,   "fg": red},     // pink bg, red text
    {"bg": yellow, "fg": orange},  // yellow bg, orange text
    {"bg": orange, "fg": yellow},  // orange bg, yellow text
    {"bg": green,  "fg": blue},    // green bg, blue text
  ];

  static const List<Color> countdownColors = [
    green,
    blue,
    red,
  ];

  static const List<Color> activityColors = [
    pink,
    orange,
    yellow,
  ];

  // Optional helper if you want rotating card colors later
  static Color countdownColorAt(int index) =>
      countdownColors[index % countdownColors.length];

  static Color activityColorAt(int index) =>
      activityColors[index % activityColors.length];

  static Map<String, Color> pairAt(int index) =>
      playfulPairs[index % playfulPairs.length];

  // ─── Shared Spacing / Radius ────────────────────
  static const double pagePadding = 20;
  static const double sectionGap = 24;
  static const double itemGap = 16;
  static const double smallGap = 8;

  static const double radiusLg = 22;
  static const double radiusMd = 18;
  static const double radiusSm = 14;

  // ─── Text Styles ────────────────────────────────
  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Georgia',
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: red,
    ),
    titleLarge: TextStyle(
      fontFamily: 'Georgia',
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: red,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Georgia',
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: blue,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: blue,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: green,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: green,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: orange,
    ),
  );

  // ─── Full ThemeData ─────────────────────────────
  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: white,
        useMaterial3: true,

        colorScheme: const ColorScheme.light(
          primary: blue,
          secondary: green,
          tertiary: pink,
          error: red,
          surface: white,
          onPrimary: green,
          onSecondary: blue,
          onSurface: blue,
        ),

        textTheme: textTheme,

        // ─── App Bar ──────────────────────────────
        appBarTheme: const AppBarTheme(
          backgroundColor: white,
          foregroundColor: red,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: red,
          ),
        ),

        // ─── Cards ────────────────────────────────
        cardTheme: CardThemeData(
          color: white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
        ),

        // ─── Inputs ───────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cream,
          hintStyle: const TextStyle(
            color: blue,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: BorderSide.none,
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: BorderSide.none,
          ),
        ),

        // ─── Elevated Buttons ─────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.disabled)) {
                return blue.withOpacity(0.35);
              }
              return blue;
            }),
            foregroundColor: MaterialStateProperty.all(green),
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            elevation: MaterialStateProperty.all(0),
            padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            textStyle: MaterialStateProperty.all(
              const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        // ─── Outlined Buttons (filled style) ──────
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(green),
            foregroundColor: MaterialStateProperty.all(blue),
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            side: MaterialStateProperty.all(BorderSide.none),
            elevation: MaterialStateProperty.all(0),
            padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            textStyle: MaterialStateProperty.all(
              const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        // ─── Text Buttons ─────────────────────────
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(orange),
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            textStyle: MaterialStateProperty.all(
              const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),

        // ─── Chips ────────────────────────────────
        chipTheme: ChipThemeData(
          backgroundColor: cream,
          selectedColor: blue,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: blue,
          ),
          secondaryLabelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: green,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),

        // ─── Divider ──────────────────────────────
        dividerTheme: const DividerThemeData(
          color: pink,
          thickness: 1,
        ),

        // ─── Bottom Navigation ────────────────────
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: white,
          indicatorColor: pink.withOpacity(0.25),
          elevation: 0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          iconTheme: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const IconThemeData(color: red, size: 26);
            }
            return const IconThemeData(color: blue, size: 24);
          }),
        ),

        // ─── Switches ─────────────────────────────
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) return yellow;
            return blue;
          }),
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) return orange;
            return green.withOpacity(0.35);
          }),
          trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
        ),

        // ─── Snackbars ────────────────────────────
        snackBarTheme: SnackBarThemeData(
          backgroundColor: green,
          contentTextStyle: const TextStyle(
            color: blue,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          behavior: SnackBarBehavior.floating,
        ),

        // ─── Progress Indicators ──────────────────
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: red,
        ),
      );
}


/// Shared layout constants — import this instead of hardcoding
/// sizes, padding, and radii in individual page files.
class AppLayout {
  // Padding
  static const double pagePadding   = 20;
  static const double cardPadding   = 18;
  static const double sectionGap    = 24;
  static const double itemGap       = 16;
  static const double smallGap      = 8;

  // Border radii
  static const double radiusXl      = 26;
  static const double radiusLg      = 22;
  static const double radiusMd      = 18;
  static const double radiusSm      = 12;

  // Countdown card
  static const double coverArtSize      = 68;
  static const double coverArtRadius    = 14;
  static const double clockBreakpoint   = 500; // px — below this, stack vertically

  // Clock digit box
  static const double digitBoxWidthFull    = 62;
  static const double digitBoxWidthCompact = 48;
  static const double digitFontFull        = 34;
  static const double digitFontCompact     = 24;
  static const double labelFontSize        = 11;
}




/// All clock color logic lives here so every widget stays in sync.
class AppClockTheme {
  // Valid user-selectable clock styles (stored in DB as these strings)
  static const String blue   = 'blue';
  static const String green  = 'green';
  static const String orange = 'orange';
  static const String yellow = 'yellow';
  static const String pink   = 'pink';
  static const String red    = 'red'; // main countdowns only — not user-selectable

  // All styles a user can pick from
  static const List<String> userStyles = [blue, green, orange, yellow, pink];

  // Outer shell color (also used for the digits)
  static Color shellColor(String style) {
    switch (style) {
      case green:  return AppTheme.green;
      case orange: return AppTheme.orange;
      case yellow: return AppTheme.yellow;
      case pink:   return AppTheme.pink;
      case red:    return AppTheme.red;
      default:     return AppTheme.blue; // blue + fallback
    }
  }

  // Highlight color — colons & labels sit on the shell, must contrast
  static Color highlightColor(String style) {
    switch (style) {
      case green:  return AppTheme.blue;
      case orange: return AppTheme.yellow;
      case yellow: return AppTheme.orange;
      case pink:   return AppTheme.red;
      case red:    return AppTheme.pink;
      default:     return AppTheme.green; // blue
    }
  }

  // Human-readable label shown in the picker
  static String label(String style) {
    switch (style) {
      case green:  return 'Green';
      case orange: return 'Orange';
      case yellow: return 'Yellow';
      case pink:   return 'Pink';
      default:     return 'Blue';
    }
  }

  // Resolves the effective style — main countdowns are always red
  static String effectiveStyle(String style, {bool isMain = false}) =>
      isMain ? red : style;
}