import '../../../../shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../domain/entities/dashboard_entity.dart';

class CompletionTimeCard extends StatelessWidget {
  final CompletionTimeEntity completionTime;

  const CompletionTimeCard({
    super.key,
    required this.completionTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 23, 24, 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Text(
                'تحليل وقت الإنجاز',
                style: AppTextStyles.titleLarge.copyWith(height: 1.1),
              ),
              SizedBox(width: 8),
              Icon(LucideIcons.timer, color: AppColors.forest, size: 20),
            ],
          ),
          const SizedBox(height: 28),
          Center(
            child: Text(
              completionTime.averageDays,
              style: AppTextStyles.displayLarge.copyWith(fontSize: 46, fontWeight: AppTextStyles.medium, height: 0.95),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'يوم — متوسط إنجاز المعاملة',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.goldDark, height: 1),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.forestLight.withOpacity(0.12),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                completionTime.comparison,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.forest, height: 1),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...completionTime.stages.map(
            (stage) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _StageProgress(stage: stage),
            ),
          ),
        ],
      ),
    );
  }
}

class _StageProgress extends StatelessWidget {
  final StageTimeEntity stage;

  const _StageProgress({required this.stage});

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        SizedBox(
          width: 94,
          child: Text(
            stage.title,
            textAlign: TextAlign.right,
            style: AppTextStyles.labelMedium.copyWith(height: 1),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: LinearProgressIndicator(
              value: stage.progress,
              minHeight: 6,
              backgroundColor: AppColors.forestLight.withOpacity(0.10),
              color: AppColors.forest,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 42,
          child: Text(
            '${stage.days} يوم',
            textAlign: TextAlign.left,
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.goldDark, height: 1),
          ),
        ),
      ],
    );
  }
}