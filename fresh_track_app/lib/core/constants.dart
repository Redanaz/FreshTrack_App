import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF006D44);
  static const Color accent = Color(0xFF006D44);
  static const Color expiringSoon = Color(0xFFD97706);
  static const Color expired = Color(0xFFB3261E);
  static const Color safe = Color(0xFF10B981);
  static const Color background = Color(0xFFF9FBF9);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
  static const Color alertExpiredBg = Color(0xFFFEF2F2);
  static const Color alertExpiredBorder = Color(0xFFFCA5A5);
  static const Color alertExpiringSoonBg = Color(0xFFFFFBEB);
  static const Color alertExpiringSoonBorder = Color(0xFFFCD34D);
}

class AppTextStyles {
  static const TextStyle appTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle appSubtitle = TextStyle(
    fontSize: 13,
    color: AppColors.textSecondary,
  );

  static const TextStyle itemName = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle itemMeta = TextStyle(
    fontSize: 13,
    color: AppColors.textSecondary,
  );

  static const TextStyle badge = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle tabLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle sectionLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle dialogTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
}