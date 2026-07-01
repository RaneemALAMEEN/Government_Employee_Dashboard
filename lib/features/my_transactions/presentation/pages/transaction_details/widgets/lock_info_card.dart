import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../../../shared/theme/app_colors.dart';

class LockInfoCard extends StatelessWidget {
  const LockInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.goldLight.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withOpacity(0.3)),
        ),
        child: const Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(LucideIcons.lock, color: AppColors.goldDark, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'الرجاء استلام المعاملة أولاً من أعلى الصفحة للبدء باتخاذ القرار وإدخال البيانات المطلوبة.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.charcoalDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
