import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class PermissionDeniedCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const PermissionDeniedCard({
    super.key,
    required this.title,
    required this.description,
    this.icon = LucideIcons.shieldAlert,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 42),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: .25),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 42, color: AppColors.goldDark),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.charcoalDark,
                  fontWeight: AppTextStyles.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.goldDark,
                ),
              ),
            ],
          ),
        ),
      );
}
