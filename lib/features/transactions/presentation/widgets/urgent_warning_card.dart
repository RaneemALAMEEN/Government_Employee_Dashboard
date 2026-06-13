import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';

class UrgentWarningCard extends StatelessWidget {
  final int urgentCount;

  const UrgentWarningCard({
    super.key,
    required this.urgentCount,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.sizeOf(context).width < 900;

    return Container(
      constraints: BoxConstraints(
        minHeight: isSmall ? 64 : 72,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 18 : 26,
        vertical: isSmall ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          right: BorderSide(
            color: AppColors.umber,
            width: 5,
          ),
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.umber,
            size: isSmall ? 24 : 28,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'لديك $urgentCount معاملات مستعجلة تحتاج توقيعك في أقرب وقت',
                  maxLines: isSmall ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.umber,
                    fontSize: isSmall ? 14 : 17,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'المعاملات المستعجلة تشمل بأيقونة التحذير',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.goldDark,
                    fontSize: isSmall ? 12 : 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
