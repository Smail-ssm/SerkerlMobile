import 'package:flutter/material.dart';

const Map<String, Color> colors = {
  'Olivine': Color(0xFF96B57E),
  'Dark spring green': Color(0xFF00663A),
  'Orange': Color(0xFFFE6600),
  'Vanilla': Color(0xFFF2F0AC),
  'Vanilla 2': Color(0xFFF0EFAC),
  'Steel Blue': Color(0xFF4682B4),
  'Charcoal': Color(0xFF36454F),
  'Light Grey': Color(0xFFD3D3D3),
  'Error Red': Color(0xFFD32F2F), // Added for error handling
};

// Light Theme
final lightTheme = ThemeData(
  primaryColor: colors['Dark spring green']!,
  highlightColor: colors['Orange']!,
  colorScheme: ColorScheme.light(
    primary: colors['Dark spring green']!,
    secondary: colors['Dark spring green']!,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    surface: Colors.white,
    onSurface: Colors.black,
    background: colors['Vanilla']!,
    error: colors['Error Red']!,
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: colors['Vanilla']!,
  textTheme: TextTheme(
    headlineMedium: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      color: colors['Charcoal']!,
    ),
    bodyMedium: TextStyle(fontSize: 16.0, color: colors['Charcoal']!),
    bodySmall: TextStyle(fontSize: 18.0, color: colors['Charcoal']!),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: colors['Vanilla']!,
    foregroundColor: colors['Charcoal']!,
    elevation: 0,
    iconTheme: IconThemeData(color: colors['Charcoal']!),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: colors['Dark spring green']!,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(color: colors['Light Grey']!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(color: colors['Dark spring green']!),
    ),
    labelStyle: TextStyle(color: colors['Charcoal']!),
    hintStyle: TextStyle(color: colors['Light Grey']!),
  ),
  dividerColor: colors['Light Grey'],
);

// Dark Theme
final darkTheme = ThemeData(
  primaryColor: colors['Dark spring green']!,
  highlightColor: colors['Orange']!,
  colorScheme: ColorScheme.dark(
    primary: colors['Dark spring green']!,
    secondary: colors['Dark spring green']!,
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    surface: Colors.black,
    onSurface: Colors.white,
    background: colors['Charcoal']!,
    error: colors['Error Red']!,
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: colors['Charcoal']!,
  textTheme: const TextTheme(
    headlineMedium: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    bodyMedium: TextStyle(fontSize: 16.0, color: Colors.white),
    bodySmall: TextStyle(fontSize: 18.0, color: Colors.white),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: colors['Charcoal']!,
    foregroundColor: Colors.white,
    elevation: 0,
    iconTheme: const IconThemeData(color: Colors.white),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: colors['Dark spring green']!,
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(color: colors['Light Grey']!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(color: colors['Dark spring green']!),
    ),
    labelStyle: const TextStyle(color: Colors.white),
    hintStyle: TextStyle(color: colors['Light Grey']!),
  ),
  dividerColor: colors['Light Grey'],
);
