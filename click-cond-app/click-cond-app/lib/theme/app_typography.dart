import 'package:click/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tipografia do app — Poppins, hierarquia clara.
class AppTypography {
  AppTypography._();

  static TextStyle display(BuildContext c) => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary(c),
        height: 1.2,
        letterSpacing: -0.5,
      );

  static TextStyle title(BuildContext c) => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary(c),
        height: 1.3,
        letterSpacing: -0.3,
      );

  static TextStyle headline(BuildContext c) => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary(c),
        height: 1.4,
      );

  static TextStyle body(BuildContext c) => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary(c),
        height: 1.5,
      );

  static TextStyle bodyMedium(BuildContext c) => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary(c),
        height: 1.5,
      );

  static TextStyle bodySecondary(BuildContext c) => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary(c),
        height: 1.5,
      );

  static TextStyle caption(BuildContext c) => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary(c),
        height: 1.4,
      );

  static TextStyle captionMedium(BuildContext c) => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary(c),
        height: 1.4,
      );

  static TextStyle tiny(BuildContext c) => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textTertiary(c),
        height: 1.3,
        letterSpacing: 0.2,
      );

  static TextStyle button(BuildContext c) => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.2,
        letterSpacing: 0.2,
      );
}
