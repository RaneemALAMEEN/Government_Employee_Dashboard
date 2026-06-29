import '../../../../shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';

class MyTxStatsCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const MyTxStatsCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          // Icon Container on the Right (in RTL)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const Spacer(),
          // Value & Label on the Left (in RTL)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: AppTextStyles.displayMedium.copyWith(fontSize: 32, color: AppColors.charcoalDark, height: 1),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(fontWeight: AppTextStyles.medium),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
