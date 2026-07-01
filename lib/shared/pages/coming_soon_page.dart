import '../theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../theme/app_colors.dart';

class ComingSoonPage extends StatelessWidget {
  final String title;

  const ComingSoonPage({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.goldLight.withOpacity(0.2),
      body: Center(
        child: SingleChildScrollView(
          child: ZoomIn(
            duration: const Duration(milliseconds: 500),
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
              constraints: const BoxConstraints(maxWidth: 480),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.gold.withOpacity(0.20)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.charcoal.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.forest.withOpacity(0.06),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.construction,
                      color: AppColors.forest,
                      size: 56,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineMedium.copyWith(fontSize: 22, height: 1.2),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'قريباً جداً',
                    style: AppTextStyles.titleMedium.copyWith(color: AppColors.goldDark),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'هذه الصفحة قيد التطوير حالياً، ونعمل بجد لإتاحتها لكم في أقرب وقت لتوفير تجربة مستخدم متكاملة ورائعة.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.charcoal.withOpacity(0.65), height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
