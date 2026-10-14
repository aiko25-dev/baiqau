import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppStyles {
  static const fontFallback = [
    'Roboto',
    'Arial',
    'Segoe UI Emoji',
    'sans-serif',
  ];
  static const cardRadius = 24.0;
  static const controlRadius = 18.0;
  static const pagePadding = EdgeInsets.fromLTRB(24, 20, 24, 32);
  static const softShadow = [
    BoxShadow(color: Color(0x0C7041C6), blurRadius: 24, offset: Offset(0, 8)),
  ];
  static const lavenderGradient = LinearGradient(
    colors: [AppColors.softPurple, Color(0xFFEDE4FF), AppColors.background],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
