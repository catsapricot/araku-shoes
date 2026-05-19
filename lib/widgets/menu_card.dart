import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_text_style.dart';

class MenuCard extends StatelessWidget {

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const MenuCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(

      onTap: onTap,

      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 10,
            )
          ],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(
              icon,
              size: 40,
              color: AppColors.primary,
            ),

            const SizedBox(height: 12),

            Text(
              title,
              style: AppTextStyle.menuTitle,
            )
          ],
        ),
      ),
    );
  }
}