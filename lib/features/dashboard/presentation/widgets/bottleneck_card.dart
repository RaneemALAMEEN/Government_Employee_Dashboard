import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/dashboard_entity.dart';

class BottleneckCard extends StatelessWidget {
  final List<BottleneckEntity> items;

  const BottleneckCard({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 21, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.umber.withOpacity(0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Row(
            textDirection: TextDirection.rtl,
            children: [
              Text(
                'تنبيه: عنق الزجاجة',
                style: TextStyle(
                  fontSize: 18,
                  height: 1.15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.umber,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.warning_amber, size: 21, color: AppColors.umber),
            ],
          ),
          const SizedBox(height: 9),
          const Text(
            'المراحل الأكثر تعطيلًا في النظام حالياً',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              height: 1,
              fontWeight: FontWeight.w400,
              color: AppColors.goldDark,
            ),
          ),
          const SizedBox(height: 18),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _BottleneckItem(item: item),
                  ),
                )
                .toList(),
          ),
          SizedBox(
            height: 36,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.umber,
                foregroundColor: AppColors.white,
                minimumSize: const Size(double.infinity, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: EdgeInsets.zero,
              ),
              child: const Text(
                'عرض تقرير تفصيلي',
                style: TextStyle(
                  fontSize: 14,
                  height: 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottleneckItem extends StatelessWidget {
  final BottleneckEntity item;

  const _BottleneckItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: AppColors.umber.withOpacity(0.22),
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.1,
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoalDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.delay,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1,
                    fontWeight: FontWeight.w400,
                    color: AppColors.goldDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.umber.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              item.count,
              style: const TextStyle(
                fontSize: 11,
                height: 1,
                fontWeight: FontWeight.w500,
                color: AppColors.umber,
              ),
            ),
          ),
        ],
      ),
    );
  }
}