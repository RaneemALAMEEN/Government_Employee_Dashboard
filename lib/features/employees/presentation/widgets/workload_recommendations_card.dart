import '../../../../shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';

class WorkloadRecommendationsCard extends StatelessWidget {
  const WorkloadRecommendationsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      const _RecommendationItem(
        text: 'مي الشيخ مثقلة بالعمل — ينصح بتحويل بعض معاملاتها',
        borderColor: AppColors.umber,
        bgColor: Color(0xFFFDF2F4),
      ),
      const _RecommendationItem(
        text: 'كريم منصور غير نشط — يمكن توجيه معاملات إليه',
        borderColor: AppColors.goldDark,
        bgColor: Color(0xFFFAF8F0),
      ),
      const _RecommendationItem(
        text: 'تامر فواز لديه طاقة إضافية — مناسب لمعاملات إضافية',
        borderColor: AppColors.forest,
        bgColor: Color(0xFFF0F7F6),
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
              Icon(LucideIcons.lightbulb, color: AppColors.forest, size: 20),
              SizedBox(width: 8),
              Text(
                'توصيات توزيع العمل',
                style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: AppTextStyles.bold, color: AppColors.forest),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: item.bgColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                    topRight: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                  border: Border(
                    right: BorderSide(
                      color: item.borderColor,
                      width: 4,
                    ),
                  ),
                ),
                child: Text(
                  item.text,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: AppTextStyles.semiBold,
                      color: item.borderColor,
                      height: 1.4),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RecommendationItem {
  final String text;
  final Color borderColor;
  final Color bgColor;

  const _RecommendationItem({
    required this.text,
    required this.borderColor,
    required this.bgColor,
  });
}
