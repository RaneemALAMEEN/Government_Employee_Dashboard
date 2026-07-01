import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:animate_do/animate_do.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

/// Empty state shown when no file has been uploaded yet.
/// Includes a mock illustration of what the results will look like.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: const Duration(milliseconds: 500),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gold.withOpacity(0.20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.forest.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.fileScan,
                color: AppColors.forest,
                size: 56,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'قم برفع صورة أو ملف PDF للبدء',
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.charcoalDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ارفع وثيقتك وسيتم تحليل الجودة تلقائيًا',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.charcoal.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),

          ],
        ),
      ),
    );
  }
}
