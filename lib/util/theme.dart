import 'package:flutter/material.dart';

const Map<String, Color> colors = {
  'Olivine': Color(0xFF96B57E),
  'Dark spring green': Color(0xFF277149),
  'Orange': Color(0xFFE87948),
  'Vanilla': Color(0xFFF0EEAB),
  'Vanilla 2': Color(0xFFF0EFAC),
  'Steel Blue': Color(0xFF4682B4), // Added for accent color
  'Charcoal': Color(0xFF36454F), // Added for darker text
  'Light Grey': Color(0xFFD3D3D3), // Added for borders and lighter elements
};

// Light Theme
final lightTheme = ThemeData(
  primaryColor: colors['Olivine']!,
  highlightColor: colors['Orange']!,
  colorScheme: ColorScheme.light(
    primary: colors['Olivine']!,
    secondary: colors['Dark spring green']!,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    surface: Colors.white,
    onSurface: Colors.black, // Text color on background
  ),
  scaffoldBackgroundColor: colors['Vanilla']!,
  textTheme: TextTheme(
    headlineMedium: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: colors['Charcoal']!),
    bodyMedium: TextStyle(fontSize: 16.0, color: colors['Charcoal']!),
    bodySmall: TextStyle(fontSize: 18.0, color: colors['Charcoal']!),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: colors['Vanilla']!,
    foregroundColor: colors['Charcoal']!,
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: colors['Olivine']!,
    textTheme: ButtonTextTheme.primary,
  ),

);

// Dark Theme
final darkTheme = ThemeData(
  primaryColor: colors['Olivine']!,
  highlightColor: colors['Orange']!,
  colorScheme: ColorScheme.dark(
    primary: colors['Olivine']!,
    secondary: colors['Dark spring green']!,
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    surface: Colors.black,
    onSurface: Colors.white,
  ),
  scaffoldBackgroundColor: colors['Charcoal']!,
  textTheme: const TextTheme(
    headlineMedium: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
    bodyMedium: TextStyle(fontSize: 16.0, color: Colors.white),
    bodySmall: TextStyle(fontSize: 18.0, color: Colors.white),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: colors['Charcoal']!,
    foregroundColor: Colors.white,
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: colors['Olivine']!,
    textTheme: ButtonTextTheme.primary,
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(color: colors['Light Grey']!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(color: colors['Olivine']!),
    ),
    labelStyle: TextStyle(color: colors['Light Grey']!),
  ),
);
