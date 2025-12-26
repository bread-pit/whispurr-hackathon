import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FontSizes {
  static const double displayLarge = 32.0;
  static const double displayMedium = 45.0;
  static const double displaySmall = 36.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
  static const double titleMedium = 14.0;
}

/// App Colors
class AppColors {
  static const Color black = Color(0xFF222222);
  static const Color background = Color(0xFFF7F7F7);

  // Mood Colors
  static const Color okay = Color(0xFFFFF2C6);
  static const Color awful = Color(0xFFFFB5B5);
  static const Color sad = Color(0xFFAAC4F5);
  static const Color happy = Color(0xFFA1BC98);
}

/// Build text theme
TextTheme _buildTextTheme() {
  return TextTheme(
    // Display Styles (Nunito)
    displayLarge: GoogleFonts.nunito(
      fontSize: FontSizes.displayLarge,
      fontWeight: FontWeight.w600,

    ),
    displayMedium: GoogleFonts.nunito(
      fontSize: FontSizes.displayMedium,
      fontWeight: FontWeight.w400,

    ),
    displaySmall: GoogleFonts.nunito(
      fontSize: FontSizes.displaySmall,
      fontWeight: FontWeight.w400,

    ),

    // Body Styles (Poppins)
    bodyLarge: GoogleFonts.poppins(
      fontSize: FontSizes.bodyLarge,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.15,

    ),
    bodyMedium: GoogleFonts.poppins(
      fontSize: FontSizes.bodyMedium,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
    ),
    bodySmall: GoogleFonts.poppins(
      fontSize: FontSizes.bodySmall,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: FontSizes.bodyMedium,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: AppColors.black,
      fontStyle: FontStyle.italic
    ),
  );
}

/// Main Theme Data Export
ThemeData createAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: _buildTextTheme(),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.black,
      surface: AppColors.background,
    ),
    extensions: <ThemeExtension<dynamic>>[
      const MoodColors(
        okay: AppColors.okay,
        awful: AppColors.awful,
        sad: AppColors.sad,
        happy: AppColors.happy,
      ),
    ],
  );
}

/// Mood Colors
@immutable
class MoodColors extends ThemeExtension<MoodColors> {
  final Color? okay;
  final Color? awful;
  final Color? sad;
  final Color? happy;

  const MoodColors({this.okay, this.awful, this.sad, this.happy});

  @override
  MoodColors copyWith({Color? okay, Color? awful, Color? sad, Color? happy}) {
    return MoodColors(
      okay: okay ?? this.okay,
      awful: awful ?? this.awful,
      sad: sad ?? this.sad,
      happy: happy ?? this.happy,
    );
  }

  @override
  MoodColors lerp(ThemeExtension<MoodColors>? other, double t) {
    if (other is! MoodColors) return this;
    return MoodColors(
      okay: Color.lerp(okay, other.okay, t),
      awful: Color.lerp(awful, other.awful, t),
      sad: Color.lerp(sad, other.sad, t),
      happy: Color.lerp(happy, other.happy, t),
    );
  }
}

// Helper extension to make theme access much shorter
extension ThemeGetter on BuildContext {
  // Access TextTheme: context.textTheme.displayLarge
  TextTheme get textTheme => Theme.of(this).textTheme;

  // Access Mood Colors: context.mood.happy
  MoodColors get mood => Theme.of(this).extension<MoodColors>()!;

  // Access General Theme: context.colorScheme.primary
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}