import 'package:flutter/material.dart';

// --- App Colors ---
const Color kEcoGreen = Color(0xFF5FBF77);
const Color kSkyBlue = Color(0xFF6CC3E2);
const Color kWhite = Color(0xFFFFFFFF);
const Color kDarkText = Color(0xFF333333);
const Color kLightText = Color(0xFF757575);
const Color kBorderGrey = Color(0xFFE0E0E0);
const Color kBackgroundLight = Color(0xFFF5F5F5);
const Color kWarningYellow = Color(0xFFFFC107);

// --- Tinted Backgrounds for Cards ---
const Color kGreenTint = Color(0xFFE8F5E9); // Light green
const Color kBlueTint = Color(0xFFE3F2FD); // Light blue
const Color kYellowTint = Color(0xFFFFF8E1); // Light yellow

// --- Text Styles ---
// We'll load 'Nunito Sans' in main.dart or home_screen.dart
// For now, these are placeholders if the font fails to load.
const TextStyle kHeaderTextStyle = TextStyle(
  fontSize: 20.0,
  fontWeight: FontWeight.bold,
  color: kDarkText,
);

const TextStyle kBodyTextStyle = TextStyle(fontSize: 16.0, color: kDarkText);

const TextStyle kSubtitleTextStyle = TextStyle(
  fontSize: 14.0,
  color: kLightText,
);
