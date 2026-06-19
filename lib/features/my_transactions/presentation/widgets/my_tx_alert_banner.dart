import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../shared/theme/app_colors.dart';

class MyTxAlertBanner extends StatelessWidget {
  final int urgentCount;

  const MyTxAlertBanner({
    super.key,
    required this.urgentCount,
  });

  @override
  Widget build(BuildContext context) {
    if (urgentCount == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.umber.withOpacity(0.06),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomLeft: Radius.circular(8),
          topRight: Radius.circular(2),
          bottomRight: Radius.circular(2),
        ),
        border: const Border(
          right: BorderSide(
            color: AppColors.umber,
            width: 4,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'لديك $urgentCount معاملات مستعجلة تحتاج توقيعك في أقرب وقت',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                    color: AppColors.umber,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'المعاملات المستعجلة مشارة بأيقونة التحذير',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.1,
                    fontWeight: FontWeight.w400,
                    color: AppColors.umber,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Icon(
            LucideIcons.alertTriangle,
            color: AppColors.umber,
            size: 24,
          ),
        ],
      ),
    );
  }
}
