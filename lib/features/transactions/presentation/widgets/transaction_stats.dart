import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

class TransactionStats extends StatelessWidget {
  final int waitingCount;
  final int urgentCount;
  final int completedCount;

  const TransactionStats({
    super.key,
    required this.waitingCount,
    required this.urgentCount,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.sizeOf(context).width < 1000;

    final cards = [
      _StatCard(
        value: waitingCount.toString(),
        title: 'بانتظار توقيعي',
        icon: Icons.edit_square,
        iconColor: AppColors.forest,
        iconBackground: AppColors.forestLight.withOpacity(0.12),
      ),
      _StatCard(
        value: urgentCount.toString(),
        title: 'مستعجلة',
        icon: Icons.warning_amber_rounded,
        iconColor: AppColors.umber,
        iconBackground: AppColors.umber.withOpacity(0.08),
      ),
      _StatCard(
        value: completedCount.toString(),
        title: 'منجزة هذا الشهر',
        icon: Icons.check_circle_outline,
        iconColor: AppColors.forest,
        iconBackground: AppColors.forestLight.withOpacity(0.12),
      ),
    ];

    if (isSmall) {
      return Column(
        children: [
          cards[0],
          const SizedBox(height: 14),
          cards[1],
          const SizedBox(height: 14),
          cards[2],
        ],
      );
    }

    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Expanded(child: cards[0]),
        const SizedBox(width: 20),
        Expanded(child: cards[1]),
        const SizedBox(width: 20),
        Expanded(child: cards[2]),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;

  const _StatCard({
    required this.value,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.sizeOf(context).width < 900;

    return Container(
      height: isSmall ? 100 : 116,
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 18 : 22,
        vertical: isSmall ? 16 : 18,
      ),
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
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: isSmall ? 34 : 40,
            height: isSmall ? 34 : 40,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: isSmall ? 19 : 21,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: isSmall ? 14 : 15,
                height: 1.25,
                fontWeight: AppTextStyles.medium,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: AppTextStyles.displayMedium.copyWith(
              fontSize: isSmall ? 30 : 36,
              height: 1,
              fontWeight: AppTextStyles.bold,
            ),
          ),
        ],
      ),
    );
  }
}
