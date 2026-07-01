import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

/// Full-screen loading overlay shown during image analysis.
class AnalysisLoadingWidget extends StatelessWidget {
  const AnalysisLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gold.withOpacity(0.20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated spinner
            SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                strokeWidth: 3.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.forest),
                backgroundColor: AppColors.forest.withOpacity(0.12),
              ),
            ),
            const SizedBox(height: 24),
            Pulse(
              infinite: true,
              duration: const Duration(milliseconds: 1500),
              child: Text(
                'جارِ تحليل جودة الوثيقة...',
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.forest,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'يرجى الانتظار',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.charcoal.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
