import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../domain/entities/dashboard_entity.dart';

class WeeklyIndicatorsCard extends StatelessWidget {
  final List<WeeklyIndicatorEntity> indicators;

  const WeeklyIndicatorsCard({
    super.key,
    required this.indicators,
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
          const Row(
            textDirection: TextDirection.rtl,
            children: [
              Text(
                'مؤشرات الأسبوع',
                style: TextStyle(
                  fontSize: 18,
                  height: 1.1,
                  fontWeight: FontWeight.w600,
                  color: AppColors.forest,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.trending_up, color: AppColors.forest, size: 20),
            ],
          ),
          const SizedBox(height: 27),
          ...indicators.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _IndicatorRow(item: item),
                if (index != indicators.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Divider(
                      height: 1,
                      color: AppColors.charcoal.withOpacity(0.10),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _IndicatorRow extends StatelessWidget {
  final WeeklyIndicatorEntity item;

  const _IndicatorRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final valueColor = item.isPositive ? AppColors.forestLight : AppColors.umber;

    return SizedBox(
      height: 34,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.title,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1,
                    fontWeight: FontWeight.w500,
                    color: AppColors.charcoalDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.subtitle,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1,
                    color: AppColors.goldDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            item.value,
            style: TextStyle(
              fontSize: 13,
              height: 1,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}