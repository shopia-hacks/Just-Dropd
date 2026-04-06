import 'package:flutter/material.dart';

class AppTheme {
  // ─── Brand Colors ───────────────────────────────
  static const Color vividGreen   = Color(0xFF11A253);
  static const Color vividBlue    = Color(0xFF1660CD);
  static const Color vividRed     = Color(0xFFF20815);
  static const Color lightMagenta = Color(0xFFFDA5E1);
  static const Color obsidian     = Color(0xFF1A1A1A);
  static const Color offWhite     = Color(0xFFF5F5F0);

  // ─── Text Styles ────────────────────────────────
  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Georgia',
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: obsidian,
    ),
    titleLarge: TextStyle(
      fontFamily: 'Georgia',
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: obsidian,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Courier',
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.06,
      color: obsidian,
    ),
    bodyLarge: TextStyle(fontSize: 16, color: obsidian),
    bodyMedium: TextStyle(fontSize: 14, color: obsidian),
    bodySmall: TextStyle(fontSize: 12, color: Color(0xFF666666)),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: vividBlue,
    ),
  );

  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: vividBlue,
          secondary: vividGreen,
          tertiary: lightMagenta,
          error: vividRed,
          surface: offWhite,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: obsidian,
        ),
        textTheme: textTheme,
        useMaterial3: true,

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: obsidian,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: obsidian,
          ),
        ),

        cardTheme: CardThemeData(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.black12, width: 0.5),
          ),
          elevation: 0,
          margin: const EdgeInsets.all(8),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return vividBlue.withValues(alpha: 0.75);
              }
              return vividBlue;
            }),
            foregroundColor: WidgetStateProperty.all(Colors.white),
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            shape: WidgetStateProperty.all(const StadiumBorder()),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            textStyle: WidgetStateProperty.all(
              const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return vividGreen;
              }
              return Colors.transparent;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return Colors.white;
              }
              return vividGreen;
            }),
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            side: WidgetStateProperty.all(
              const BorderSide(color: vividGreen, width: 1.5),
            ),
            shape: WidgetStateProperty.all(const StadiumBorder()),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            textStyle: WidgetStateProperty.all(
              const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return lightMagenta;
              }
              return Colors.transparent;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return obsidian;
              }
              return vividBlue;
            }),
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            textStyle: WidgetStateProperty.all(
              const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: offWhite,
          hintStyle: const TextStyle(color: Colors.grey),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black26),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: vividBlue, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black26),
          ),
        ),

        dividerTheme: const DividerThemeData(
          color: Colors.black12,
          thickness: 0.5,
        ),

        listTileTheme: const ListTileThemeData(
          iconColor: obsidian,
          textColor: obsidian,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),

        popupMenuTheme: PopupMenuThemeData(
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            color: obsidian,
          ),
        ),

        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
        ),

        snackBarTheme: SnackBarThemeData(
          backgroundColor: obsidian,
          contentTextStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
        ),

        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return vividBlue;
            }
            return Colors.white;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return vividBlue.withValues(alpha: 0.4);
            }
            return Colors.grey.shade300;
          }),
        ),
      );
}