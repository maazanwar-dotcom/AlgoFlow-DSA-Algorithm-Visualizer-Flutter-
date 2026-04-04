import 'package:flutter/material.dart';

getTheme() {
  final Color seed = const Color.fromARGB(255, 216, 70, 239);
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
      secondary: Color.fromARGB(255, 0, 238, 255),
    ),

    scaffoldBackgroundColor: const Color.fromARGB(255, 15, 10, 24),
    canvasColor: const Color(0xFF0F172A),
    cardTheme: CardThemeData(
      color: const Color(0xFF1B1429),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: const Color(0xFF2E243F), width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: seed,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color.fromARGB(255, 21, 34, 59),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(fontSize: 16),
      bodyMedium: TextStyle(fontSize: 14),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color.fromARGB(
        255,
        27,
        20,
        41,
      ), // same as card color
      selectedItemColor: seed, // primary (seed) color for selected item
      unselectedItemColor: const Color.fromARGB(
        255,
        95,
        75,
        133,
      ), // color for unselected labels/icons
      selectedIconTheme: IconThemeData(color: seed),
      unselectedIconTheme: const IconThemeData(
        color: Color.fromARGB(255, 95, 75, 133),
      ),
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
