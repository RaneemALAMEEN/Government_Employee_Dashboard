import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';

class InternalStatsSection extends StatelessWidget {
  final int total;
  final int inProgress;
  final int completed;

  const InternalStatsSection({
    super.key,
    required this.total,
    required this.inProgress,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.sizeOf(context).width < 1100;

    final cards = [
      _StatCard(
        value: total.toString(),
        title: 'إجمالي المعاملات',
        icon: Icons.description_outlined,
        iconColor: AppColors.forest,
      ),
      _StatCard(
        value: inProgress.toString(),
        title: 'قيد المعالجة',
        icon: Icons.assignment_outlined,
        iconColor: AppColors.goldDark,
      ),
      _StatCard(
        value: completed.toString(),
        title: 'منجزة',
        icon: Icons.task_outlined,
        iconColor: AppColors.forest,
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: isSmall
          ? Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.start,
              children: cards
                  .map(
                    (card) => SizedBox(
                      width: MediaQuery.sizeOf(context).width < 600
                          ? double.infinity
                          : (MediaQuery.sizeOf(context).width - 80) / 2,
                      child: card,
                    ),
                  )
                  .toList(),
            )
          : Row(
              children: [
                Expanded(child: cards[0]),
                const SizedBox(width: 20),
                Expanded(child: cards[1]),
                const SizedBox(width: 20),
                Expanded(child: cards[2]),
              ],
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String title;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.value,
    required this.title,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 116,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: iconColor, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.charcoal,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.forest,
              fontSize: 32,
              height: 1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}