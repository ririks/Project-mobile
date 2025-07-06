import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Colors
class AppColors {
  static const Color primaryBlue = Color(0xFF1A45A0);
  static const Color secondaryBlue = Color(0xFF2563EB);
  static const Color accentYellow = Color(0xFFF5B500);
  static const Color accentRed = Color(0xFFE83C3C);
  static const Color accentGray = Color(0xFF9E9E9E);
  static const Color greenStatus = Color(0xFF10B981);
  static const Color backgroundColor = Colors.white;
  static const Color cardBackground = Colors.white;
  static const Color lightGrayBackground = Color(0xFFF0F0F0);
  static const Color primaryText = Color(0xFF2D3748);
  static const Color secondaryText = Color(0xFF718096);
  static const Color lightBorder = Color(0xFFF0F0F0);
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A45A0), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// Sizes
class AppSizes {
  static const double borderRadius = 12.0;
  static const double cardPadding = 16.0;
  static const double spacing = 16.0;
  static const double smallSpacing = 8.0;
  static const double iconSize = 24.0;
  static const double smallIconSize = 16.0;
  static const double mobileMargin = 16.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonHeight = 48.0;
}

// Text Styles dengan Montserrat
class AppTextStyles {
  static TextStyle get header => GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );
  
  static TextStyle get subtitle => GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );
  
  static TextStyle get body => GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryText,
  );
  
  static TextStyle get caption => GoogleFonts.montserrat(
    fontSize: 12,
    color: AppColors.secondaryText,
  );
  
  static TextStyle get whiteHeader => GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  
  static TextStyle get whiteSubtitle => GoogleFonts.montserrat(
    fontSize: 14,
    color: Colors.white70,
  );
}

// Enums
enum UserRole { staf, hrd, rektor }
enum StatusCuti { pending, disetujui, ditolak, dibatalkan }
enum TipeCuti { tahunan, sakit, lainnya }

// Status Extensions
extension StatusCutiExtension on StatusCuti {
  String get label {
    switch (this) {
      case StatusCuti.pending:
        return 'Menunggu';
      case StatusCuti.disetujui:
        return 'Disetujui';
      case StatusCuti.ditolak:
        return 'Ditolak';
      case StatusCuti.dibatalkan:
        return 'Dibatalkan';
    }
  }
  
  Color get color {
    switch (this) {
      case StatusCuti.pending:
        return AppColors.accentYellow;
      case StatusCuti.disetujui:
        return AppColors.greenStatus;
      case StatusCuti.ditolak:
        return AppColors.accentRed;
      case StatusCuti.dibatalkan:
        return AppColors.accentGray;
    }
  }
  
  IconData get icon {
    switch (this) {
      case StatusCuti.pending:
        return Icons.schedule;
      case StatusCuti.disetujui:
        return Icons.check_circle;
      case StatusCuti.ditolak:
        return Icons.cancel;
      case StatusCuti.dibatalkan:
        return Icons.block;
    }
  }
}

extension TipeCutiExtension on TipeCuti {
  String get label {
    switch (this) {
      case TipeCuti.tahunan:
        return 'Cuti Tahunan';
      case TipeCuti.sakit:
        return 'Cuti Sakit';
      case TipeCuti.lainnya:
        return 'Cuti Lainnya';
    }
  }
}

extension UserRoleExtension on UserRole {
  String get label {
    switch (this) {
      case UserRole.staf:
        return 'Staf';
      case UserRole.hrd:
        return 'Admin';
      case UserRole.rektor:
        return 'Rektor';
    }
  }
}

