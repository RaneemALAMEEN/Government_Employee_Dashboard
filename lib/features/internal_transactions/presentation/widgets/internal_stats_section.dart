import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';

class InternalStatsSection extends StatelessWidget {
  final int categoriesCount;

  const InternalStatsSection({
    super.key,
    required this.categoriesCount,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.sizeOf(context).width < 1000;

    final cards = [
      _StatCard(
        value: '12',
        title: 'إجمالي المعاملات',
        icon: Icons.description_outlined,
        iconColor: AppColors.forest,
      ),
      _StatCard(
        value: '5',
        title: 'قيد الانتظار',
        icon: Icons.article_outlined,
        iconColor: AppColors.forest,
      ),
      _StatCard(
        value: '4',
        title: 'قيد المعالجة',
        icon: Icons.assignment_outlined,
        iconColor: AppColors.goldDark,
      ),
      _StatCard(
        value: '3',
        title: 'منجزة',
        icon: Icons.task_outlined,
        iconColor: AppColors.forest,
      ),
    ];

    if (isSmall) {
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: cards
            .map(
              (card) => SizedBox(
                width: 260,
                child: card,
              ),
            )
            .toList(),
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
        const SizedBox(width: 20),
        Expanded(child: cards[3]),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: iconColor, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.charcoal,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.forest,
              fontSize: 36,
              height: 1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}