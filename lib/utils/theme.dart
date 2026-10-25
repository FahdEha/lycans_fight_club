import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Color(AppConstants.bg),
      colorScheme: ColorScheme.dark(
        primary: Color(AppConstants.gold),
        secondary: Color(AppConstants.goldSoft),
        surface: Color(AppConstants.bgCard),
        error: Color(AppConstants.ember),
      ),
      fontFamily: 'Manrope',
      textTheme: TextTheme(
        displayLarge: GoogleFonts.oswald(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Color(AppConstants.ink),
        ),
        displayMedium: GoogleFonts.oswald(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Color(AppConstants.ink),
        ),
        titleLarge: GoogleFonts.oswald(
          fontSize: 19,
          fontWeight: FontWeight.w600,
          color: Color(AppConstants.ink),
        ),
        titleMedium: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(AppConstants.ink),
        ),
        bodyLarge: GoogleFonts.manrope(
          fontSize: 13.5,
          color: Color(AppConstants.ink),
        ),
        bodyMedium: GoogleFonts.manrope(
          fontSize: 12,
          color: Color(AppConstants.inkDim),
        ),
        bodySmall: GoogleFonts.manrope(
          fontSize: 11,
          color: Color(AppConstants.inkFaint),
        ),
        labelLarge: GoogleFonts.jetBrainsMono(
          fontSize: 10.5,
          letterSpacing: 0.1,
          color: Color(AppConstants.goldSoft),
        ),
        labelMedium: GoogleFonts.jetBrainsMono(
          fontSize: 10,
          letterSpacing: 0.08,
          color: Color(AppConstants.inkDim),
        ),
      ),
    );
  }
}