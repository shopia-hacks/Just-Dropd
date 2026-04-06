// lib/theme/theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // ─── Brand Colors ───────────────────────────────
  static const Color vividGreen    = Color(0xFF11A253);
  static const Color vividBlue     = Color(0xFF1660CD);
  static const Color vividRed      = Color(0xFFF20815);
  static const Color lightMagenta  = Color(0xFFFDA5E1);
  static const Color obsidian      = Color(0xFF1A1A1A);
  static const Color offWhite      = Color(0xFFF5F5F0);

  // ─── Text Styles ────────────────────────────────
  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(fontFamily: 'Georgia', fontSize: 32, fontWeight: FontWeight.w700, color: obsidian),
    titleLarge:   TextStyle(fontFamily: 'Georgia', fontSize: 22, fontWeight: FontWeight.w700, color: obsidian),
    titleMedium:  TextStyle(fontFamily: 'Courier', fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.06, color: obsidian),
    bodyLarge:    TextStyle(fontSize: 16, color: obsidian),
    bodyMedium:   TextStyle(fontSize: 14, color: obsidian),
    bodySmall:    TextStyle(fontSize: 12, color: Color(0xFF666666)),
    labelLarge:   TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: vividBlue),
  );

  // ─── Full ThemeData ──────────────────────────────
  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.light(
      primary:    vividBlue,
      secondary:  vividGreen,
      tertiary:   lightMagenta,
      error:      vividRed,
      surface:    offWhite,
      onPrimary:  Colors.white,
      onSecondary: Colors.white,
      onSurface:  obsidian,
    ),
    textTheme: textTheme,
    useMaterial3: true,

    // ─── Navigation Bar ─────────────────────────
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: vividBlue.withOpacity(0.12),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return IconThemeData(color: vividBlue, size: 24);
        }
        return IconThemeData(color: Colors.grey, size: 24);
      }),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
    ),

    // ─── Elevated Buttons ────────────────────────
    // Filled with color at rest, slightly darker when pressed
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return vividBlue.withOpacity(0.75);
          }
          return vividBlue;
        }),
        foregroundColor: MaterialStateProperty.all(Colors.white),
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        shape: MaterialStateProperty.all(StadiumBorder()),
        padding: MaterialStateProperty.all(
          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        textStyle: MaterialStateProperty.all(
          TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    ),

    // ─── Outlined Buttons ────────────────────────
    // Outlined at rest, fills with the outline color when pressed
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return vividGreen;
          }
          return Colors.transparent;
        }),
        foregroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return Colors.white;
          }
          return vividGreen;
        }),
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        side: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return BorderSide(color: vividGreen, width: 1.5);
          }
          return BorderSide(color: vividGreen, width: 1.5);
        }),
        shape: MaterialStateProperty.all(StadiumBorder()),
        padding: MaterialStateProperty.all(
          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        textStyle: MaterialStateProperty.all(
          TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    ),

    // ─── Text Buttons ────────────────────────────
    // Text only at rest, fills with magenta when pressed
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return lightMagenta;
          }
          return Colors.transparent;
        }),
        foregroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return obsidian;
          }
          return vividBlue;
        }),
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        textStyle: MaterialStateProperty.all(
          TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    ),

    // ─── Cards ───────────────────────────────────
    cardTheme: CardThemeData(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.black12, width: 0.5),
      ),
      elevation: 0,
      margin: EdgeInsets.all(8),
    ),

    // ─── Input Fields ────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: offWhite,
      hintStyle: TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black26),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: vividBlue, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black26),
      ),
    ),

    // ─── App Bar ─────────────────────────────────
    appBarTheme: AppBarTheme(
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

    // ─── Chip (tab toggles: "Friends" / "Me") ────
    chipTheme: ChipThemeData(
      backgroundColor: offWhite,
      selectedColor: vividBlue,
      labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: obsidian),
      secondaryLabelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
      shape: StadiumBorder(side: BorderSide(color: Colors.black12)),
    ),

    // ─── Divider ─────────────────────────────────
    dividerTheme: DividerThemeData(
      color: Colors.black12,
      thickness: 0.5,
    ),
  );
}