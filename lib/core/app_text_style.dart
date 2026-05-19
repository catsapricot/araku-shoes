import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyle {

  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle subHeading = TextStyle(
    fontSize: 16,
    color: AppColors.textSecondary,
  );

  static const TextStyle menuTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
}