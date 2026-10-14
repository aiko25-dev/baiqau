import 'package:flutter/material.dart';

/// Shared semantic palette for every screen and Material component.
abstract final class AppColors {
  static const primary = Color(0xFF8B5CF6);
  static const primaryLight = Color(0xFFA78BFA);
  static const accent = Color(0xFFC4B5FD);
  // Deeper purple keeps small text and white button labels easy to read.
  static const primaryStrong = Color(0xFF7041C6);
  static const primaryAction = Color(0xFF8050DF);
  static const background = Color(0xFFF8F7FF);
  static const surface = Color(0xFFFFFFFF);
  static const softPurple = Color(0xFFF3EEFF);
  static const textPrimary = Color(0xFF2F2A3A);
  static const textSecondary = Color(0xFF7B728A);
  static const border = Color(0xFFE9E2F7);
  static const success = Color(0xFFA7F3D0);
  static const successSurface = Color(0xFFEAFBF3);
  static const successInk = Color(0xFF2D7458);
  static const warning = Color(0xFFFDE68A);
  static const warningSurface = Color(0xFFFFF8DF);
  static const warningInk = Color(0xFF886727);
  static const error = Color(0xFFB34E68);
  static const errorSurface = Color(0xFFFFEFF3);
  static const design = Color(0xFF8861BD);
  static const art = Color(0xFF9A62B4);
  static const science = Color(0xFF6D72BC);
  static const literature = Color(0xFF8D6EAD);
  static const silverInk = Color(0xFF77708F);
  static const bronzeInk = Color(0xFF996C54);
  static const silverSurface = Color(0xFFF1EEF7);
  static const bronzeSurface = Color(0xFFFAEFE8);

  static Color pastelFor(Color color) {
    if (color == successInk) return successSurface;
    if (color == warningInk) return warningSurface;
    if (color == error) return errorSurface;
    if (color == textSecondary) return background;
    return softPurple;
  }
}
