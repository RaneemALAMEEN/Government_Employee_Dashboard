import '../../../../shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';

class DeptTxStatsCard extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const DeptTxStatsCard({
    super.key,
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: AppTextStyles.displayMedium.copyWith(fontSize: 32, color: valueColor, height: 1),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(fontWeight: AppTextStyles.medium),
          ),
        ],
      ),
    );
  }
}
