import '../../../../shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';

class DeptWorkloadCard extends StatelessWidget {
  const DeptWorkloadCard({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      const _WorkloadItem(
        name: 'الشؤون الإدارية',
        ratio: '12/28',
        status: 'متوسط',
        color: AppColors.goldDark,
        progress: 0.45,
      ),
      const _WorkloadItem(
        name: 'الموارد البشرية',
        ratio: '8/19',
        status: 'ضغط عالٍ',
        color: AppColors.umber,
        progress: 0.90, // visuals show red high load progress bar
      ),
      const _WorkloadItem(
        name: 'الشؤون القانونية',
        ratio: '3/14',
        status: 'طبيعي',
        color: AppColors.forest,
        progress: 0.21,
      ),
      const _WorkloadItem(
        name: 'التعليم الأساسي',
        ratio: '14/22',
        status: 'طبيعي',
        color: AppColors.forest,
        progress: 0.63,
      ),
      const _WorkloadItem(
        name: 'التخطيط',
        ratio: '4/9',
        status: 'طبيعي',
        color: AppColors.forest,
        progress: 0.44,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(LucideIcons.barChart2, color: AppColors.forest, size: 20),
              SizedBox(width: 8),
              Text(
                'توزيع الأحمال بالدوائر',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: AppTextStyles.bold, color: AppColors.forest),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = items[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.name,
                        style: AppTextStyles.bodySmall.copyWith(fontWeight: AppTextStyles.semiBold, color: AppColors.charcoalDark),
                      ),
                      Text(
                        item.ratio,
                        style: AppTextStyles.labelMedium.copyWith(fontWeight: AppTextStyles.medium, color: AppColors.charcoal.withOpacity(0.6)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: item.progress,
                      minHeight: 6,
                      backgroundColor: AppColors.goldLight,
                      valueColor: AlwaysStoppedAnimation<Color>(item.color),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft, // Align left so in RTL it shows on left side under progress bar
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.status,
                          style: AppTextStyles.labelMedium.copyWith(fontWeight: AppTextStyles.medium, color: item.color),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          item.color == AppColors.umber
                              ? LucideIcons.alertTriangle
                              : item.color == AppColors.goldDark
                                  ? LucideIcons.trendingUp
                                  : LucideIcons.checkCircle,
                          size: 12,
                          color: item.color,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WorkloadItem {
  final String name;
  final String ratio;
  final String status;
  final Color color;
  final double progress;

  const _WorkloadItem({
    required this.name,
    required this.ratio,
    required this.status,
    required this.color,
    required this.progress,
  });
}
