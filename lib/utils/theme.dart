import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Theme Notifier ---
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  void _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? ThemeMode.light.index;
    _themeMode = ThemeMode.values[themeIndex];
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDarkMode) async {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, _themeMode.index);
    notifyListeners();
  }
}

// --- Colors ---
const Color kEcoGreen = Color(0xFF5FBF77);
const Color kEcoGreenAccent = Color(0xFF8CF2A4);
const Color kSkyBlue = Color(0xFF6CC3E2);
const Color kWhite = Color(0xFFFFFFFF);
const Color kLightBg = Color(0xFFF7F9FC);
const Color kDarkBg = Color(0xFF121212);
const Color kDarkCard = Color(0xFF1E1E1E);
const Color kDarkText = Color(0xFF333333);
const Color kLightText = Color(0xFFF5F5F5);
const Color kWarningYellow = Color(0xFFE2B93B);
const Color kSpamOrange = Color(0xFFE27D60);
const Color kPimPurple = Color(0xFF8A60E2);
const Color kCarbonGrey = Color(0xFF607D8B);
const Color kTrustBlue = Color(0xFF03A9F4);

// --- Typography ---
TextTheme _buildTextTheme(TextTheme base) {
  return base
      .copyWith(
        // ... using Roboto as requested ...
      )
      .apply(fontFamily: GoogleFonts.roboto().fontFamily);
}

// --- Light Theme ---
ThemeData lightTheme = ThemeData(
  // --- FIX: Corrected BrightSymmetry to Brightness ---
  brightness: Brightness.light,
  primaryColor: kEcoGreen,
  scaffoldBackgroundColor: kLightBg,
  colorScheme: const ColorScheme.light(
    primary: kEcoGreen,
    secondary: kSkyBlue,
    surface: kWhite,
    error: kSpamOrange,
    onPrimary: kWhite,
    onSecondary: kWhite,
    onSurface: kDarkText,
    onError: kWhite,
  ),
  fontFamily: GoogleFonts.roboto().fontFamily,
  textTheme: _buildTextTheme(
    ThemeData.light().textTheme,
  ).apply(bodyColor: kDarkText, displayColor: kDarkText),
  appBarTheme: const AppBarTheme(
    backgroundColor: kLightBg,
    elevation: 0,
    iconTheme: IconThemeData(color: kDarkText),
    titleTextStyle: TextStyle(
      color: kDarkText,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 1,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: kWhite,
    shadowColor: Colors.black.withOpacity(0.05),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: kEcoGreen,
    foregroundColor: kWhite,
    elevation: 4,
    shape: CircleBorder(),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: kWhite,
    indicatorColor: kEcoGreen.withOpacity(0.15),
    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const TextStyle(
          color: kEcoGreen,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        );
      }
      return const TextStyle(color: kDarkText, fontSize: 12);
    }),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(color: kEcoGreen, size: 28);
      }
      return const IconThemeData(color: kDarkText, size: 26);
    }),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: Colors.grey.shade200,
    selectedColor: kEcoGreen,
    labelStyle: const TextStyle(color: kDarkText),
    secondaryLabelStyle: const TextStyle(color: kWhite),
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    side: BorderSide.none,
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: kWhite,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
);

// --- Dark Theme ---
ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: kEcoGreen,
  scaffoldBackgroundColor: kDarkBg,
  colorScheme: const ColorScheme.dark(
    primary: kEcoGreen,
    secondary: kSkyBlue,
    surface: kDarkCard,
    error: kSpamOrange,
    onPrimary: kWhite,
    onSecondary: kWhite,
    onSurface: kLightText,
    onError: kWhite,
  ),
  fontFamily: GoogleFonts.roboto().fontFamily,
  textTheme: _buildTextTheme(
    ThemeData.dark().textTheme,
  ).apply(bodyColor: kLightText, displayColor: kLightText),
  appBarTheme: const AppBarTheme(
    backgroundColor: kDarkBg,
    elevation: 0,
    iconTheme: IconThemeData(color: kLightText),
    titleTextStyle: TextStyle(
      color: kLightText,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 1,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: kDarkCard,
    shadowColor: Colors.black.withOpacity(0.1),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: kEcoGreen,
    foregroundColor: kWhite,
    elevation: 4,
    shape: CircleBorder(),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: kDarkCard,
    indicatorColor: kEcoGreen.withOpacity(0.25),
    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const TextStyle(
          color: kEcoGreen,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        );
      }
      return const TextStyle(color: kLightText, fontSize: 12);
    }),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(color: kEcoGreen, size: 28);
      }
      return const IconThemeData(color: kLightText, size: 26);
    }),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: Colors.grey.shade800,
    selectedColor: kEcoGreen,
    labelStyle: const TextStyle(color: kLightText),
    secondaryLabelStyle: const TextStyle(color: kWhite),
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    side: BorderSide.none,
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: kDarkCard,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
);
