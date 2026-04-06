import 'package:flutter/material.dart';

class AppTheme {
  // ─── Brand Colors ───────────────────────────────
  static const Color vividGreen   = Color(0xFF11A253);
  static const Color vividBlue    = Color(0xFF1660CD);
  static const Color vividRed     = Color(0xFFF20815);
  static const Color lightPink    = Color(0xFFFDA5E1);
  static const Color vividOrange  = Color(0xFFFD6B04);
  static const Color vividYellow  = Color(0xFFF9CB0A);
  static const Color obsidian     = Color(0xFF1A1A1A);
  static const Color offWhite     = Color(0xFFF5F5F0);

  // ─── Color Pair Helpers ─────────────────────────
  // These are your signature “opposite color” combos
  static const List<Map<String, Color>> playfulPairs = [
    {"bg": vividBlue,   "fg": vividGreen},   // blue bg, green text
    {"bg": vividRed,    "fg": lightPink},    // red bg, pink text
    {"bg": lightPink,   "fg": vividRed},     // pink bg, red text
    {"bg": vividYellow, "fg": vividOrange},  // yellow bg, orange text
    {"bg": vividOrange, "fg": vividYellow},  // orange bg, yellow text
    {"bg": vividGreen,  "fg": vividBlue},    // green bg, blue text
  ];

  static const List<Color> countdownColors = [
    vividGreen,
    vividRed,
    vividBlue,
  ];

  static const List<Color> activityColors = [
    lightPink,
    vividOrange,
    vividYellow,
  ];

  // ─── Text Styles ────────────────────────────────
  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Georgia',
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: vividRed,
    ),
    titleLarge: TextStyle(
      fontFamily: 'Georgia',
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: vividBlue,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Georgia',
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: vividGreen,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: vividBlue,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: vividGreen,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      color: vividRed,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: vividOrange,
    ),
  );

  // ─── Full ThemeData ──────────────────────────────
  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: offWhite,
        useMaterial3: true,

        colorScheme: const ColorScheme.light(
          primary: vividBlue,
          secondary: vividGreen,
          tertiary: lightPink,
          error: vividRed,
          surface: Colors.white,
          onPrimary: vividGreen,
          onSecondary: vividBlue,
          onSurface: vividBlue,
        ),

        textTheme: textTheme,

        // ─── App Bar ──────────────────────────────
        appBarTheme: const AppBarTheme(
          backgroundColor: offWhite,
          foregroundColor: vividRed,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: vividRed,
          ),
        ),

        // ─── Cards ────────────────────────────────
        // No borders — cleaner look
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),

        // ─── Inputs ───────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: const TextStyle(
            color: Color(0xFF888888),
            fontSize: 14,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),

        // ─── Elevated Buttons ─────────────────────
        // Default app button: blue bg + green text
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.disabled)) {
                return vividBlue.withOpacity(0.35);
              }
              return vividBlue;
            }),
            foregroundColor: MaterialStateProperty.all(vividGreen),
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

        // ─── Outlined Buttons ─────────────────────
        // Make these filled too, but with green bg + blue text
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(vividGreen),
            foregroundColor: MaterialStateProperty.all(vividBlue),
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
            foregroundColor: MaterialStateProperty.all(vividOrange),
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
          backgroundColor: Colors.white,
          selectedColor: vividBlue,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: vividBlue,
          ),
          secondaryLabelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: vividGreen,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),

        // ─── Divider ──────────────────────────────
        dividerTheme: const DividerThemeData(
          color: Color(0xFFEAEAEA),
          thickness: 1,
        ),

        // ─── Bottom Navigation ────────────────────
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: lightPink.withOpacity(0.25),
          elevation: 0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          iconTheme: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const IconThemeData(color: vividRed, size: 26);
            }
            return const IconThemeData(color: vividBlue, size: 24);
          }),
        ),

        // ─── Switches ─────────────────────────────
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) return vividYellow;
            return Colors.white;
          }),
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) return vividOrange;
            return Colors.grey.shade300;
          }),
        ),

        // ─── Snackbars ────────────────────────────
        snackBarTheme: SnackBarThemeData(
          backgroundColor: vividGreen,
          contentTextStyle: const TextStyle(
            color: vividBlue,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
}