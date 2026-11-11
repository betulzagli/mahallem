import 'package:flutter/material.dart';

/// Centralized color tokens for Mahallem application.
/// Strictly follows design.md specification with WCAG AA accessibility adjustments.
class AppColors {
  AppColors._();

  // Brand Identity Colors
  static const Color mahallemBlue = Color(0xFF3158C9);
  static const Color mahallemCoral = Color(0xFFFF795E);

  // Light Theme Tokens
  static const Color lightPrimary = Color(0xFF3158C9);
  static const Color lightPrimaryHover = Color(0xFF2749AC);
  static const Color lightPrimaryContainer = Color(0xFFE5EBFF);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightOnPrimaryContainer = Color(0xFF132766);

  static const Color lightSecondary = Color(0xFFFF795E);
  static const Color lightSecondaryContainer = Color(0xFFFFF0EB);
  static const Color lightOnSecondary = Color(0xFF2A1108); // High contrast on coral
  static const Color lightOnSecondaryContainer = Color(0xFF8C2E17); // Campaign text > 4.5:1

  static const Color lightBackground = Color(0xFFF7F8FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFEEF1F7);
  static const Color lightOnSurface = Color(0xFF20283A);
  
  // WCAG AA adjustment: darkened from #687386 to #4A5568 for >= 4.5:1 against lightSurface/SurfaceVariant
  static const Color lightOnSurfaceVariant = Color(0xFF4A5568);
  static const Color lightOutline = Color(0xFFD9DFEA);

  // WCAG AA adjustment: darkened from #D64545 to #C02626 for >= 4.5:1 on white
  static const Color lightError = Color(0xFFC02626);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightErrorContainer = Color(0xFFFDE8E8);
  static const Color lightOnErrorContainer = Color(0xFF7A1414);

  static const Color lightSuccess = Color(0xFF1B6B49);
  static const Color lightOnSuccess = Color(0xFFFFFFFF);
  static const Color lightSuccessContainer = Color(0xFFE6F5EE);

  static const Color lightWarning = Color(0xFFB46506);
  static const Color lightOnWarning = Color(0xFFFFFFFF);
  static const Color lightWarningContainer = Color(0xFFFEF3E4);

  // Dark Theme Tokens
  static const Color darkPrimary = Color(0xFFA9BCFF);
  static const Color darkPrimaryHover = Color(0xFFC0CDFF);
  static const Color darkPrimaryContainer = Color(0xFF243A78);
  static const Color darkOnPrimary = Color(0xFF17264D);
  static const Color darkOnPrimaryContainer = Color(0xFFD9E2FF);

  static const Color darkSecondary = Color(0xFFFFAA96);
  static const Color darkSecondaryContainer = Color(0xFF57342F);
  static const Color darkOnSecondary = Color(0xFF4A1A10);
  static const Color darkOnSecondaryContainer = Color(0xFFFFDAD2);

  static const Color darkBackground = Color(0xFF111827);
  static const Color darkSurface = Color(0xFF1A2435);
  static const Color darkSurfaceVariant = Color(0xFF263247);
  static const Color darkOnSurface = Color(0xFFF1F4FA);
  static const Color darkOnSurfaceVariant = Color(0xFFB1BCD0);
  static const Color darkOutline = Color(0xFF3C4960);

  static const Color darkError = Color(0xFFFF8585);
  static const Color darkOnError = Color(0xFF5A0000);
  static const Color darkErrorContainer = Color(0xFF4F1A1A);
  static const Color darkOnErrorContainer = Color(0xFFFFDAD6);

  static const Color darkSuccess = Color(0xFF66D6A0);
  static const Color darkOnSuccess = Color(0xFF003822);
  static const Color darkSuccessContainer = Color(0xFF104A30);

  static const Color darkWarning = Color(0xFFFFC16D);
  static const Color darkOnWarning = Color(0xFF492900);
  static const Color darkWarningContainer = Color(0xFF5E3800);
}

