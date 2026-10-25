// lib/utils/constants.dart
import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Lycans Fight Club';
  static const String organization = 'com.lycans';

  // Renkler - int olarak tut
  static const int bg = 0xFF0A0906;
  static const int bg1 = 0xFF100E0A;
  static const int bgCard = 0xFF1A160F;
  static const int bgCard2 = 0xFF221C13;
  static const int gold = 0xFFD4AF37;
  static const int goldSoft = 0xFFF2CF6C;
  static const int goldDim = 0xFF8A7228;
  static const int ember = 0xFFC1272D;
  static const int emberGlow = 0xFFFF4D4D;
  static const int ink = 0xFFF5EFE2;
  static const int inkDim = 0xFFA89C85;
  static const int inkFaint = 0xFF6E6452;
  static const int green = 0xFF5FB87A;

  // Firebase Paths
  static const String usersPath = 'users';
  static const String membershipsPath = 'memberships';
  static const String classesPath = 'classes';
  static const String schedulesPath = 'schedules';
  static const String fightsPath = 'fights';
  static const String notificationsPath = 'notifications';
  static const String invoicesPath = 'invoices';
  static const String exercisesPath = 'exercises';
  static const String progressPath = 'progress';
  static const String attendancePath = 'attendance';
  static const String checkInsPath = 'checkins';
  static const String packagesPath = 'packages';
  static const String branchesPath = 'branches';
  static const String planRequestsPath = 'plan_requests';
  static const String dailyCombosPath = 'daily_combos';
}

// Yardımcı sınıf - opacity ile renk oluşturma
class AppColors {
  static Color color(int colorValue) => Color(colorValue);

  static Color withOpacity(int colorValue, double opacity) {
    return Color(colorValue).withValues(alpha: opacity);
  }

  // Sık kullanılan opacity değerleri
  static Color goldTransparent = Color(AppConstants.gold).withValues(alpha: 0.16);
  static Color goldLight = Color(AppConstants.gold).withValues(alpha: 0.08);
  static Color goldVeryLight = Color(AppConstants.gold).withValues(alpha: 0.05);
  static Color inkTransparent = Color(AppConstants.ink).withValues(alpha: 0.07);
  static Color inkLight = Color(AppConstants.ink).withValues(alpha: 0.12);
  static Color emberTransparent = Color(AppConstants.ember).withValues(alpha: 0.12);
  static Color greenTransparent = Color(AppConstants.green).withValues(alpha: 0.12);
}