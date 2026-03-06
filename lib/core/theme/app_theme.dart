import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Paleta de Cores
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color secondaryBlue = Color(0xFF3B82F6);
  static const Color lightBlue = Color(0xFFDBEAFE);
  static const Color white = Color(0xFFFFFFFF);
  
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  
  // Status Colors
  static const Color statusPaid = Color(0xFF16A34A);      // Verde
  static const Color statusPending = Color(0xFFF59E0B);   // Amarelo
  static const Color statusCanceled = Color(0xFFDC2626);  // Vermelho

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: white,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: secondaryBlue,
        surface: white,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
