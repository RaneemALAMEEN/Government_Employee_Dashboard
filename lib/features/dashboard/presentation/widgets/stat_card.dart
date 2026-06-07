import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/dashboard_entity.dart';

class StatCard extends StatelessWidget {
  final StatEntity stat;

  const StatCard({
    super.key,
    required this.stat,
  });

  IconData get _icon {
    switch (stat.type) {
      case 'done':
        return Icons.check_circle_outline;
      case 'urgent':
        return Icons.bolt_outlined;
      case 'sign':
        return Icons.edit_square;
      default:
        return Icons.inbox_outlined;
    }
  }

  Color get _iconBg {
    if (stat.type == 'urgent') return AppColors.umber.withOpacity(0.08);
    if (stat.type == 'inbox') return AppColors.gold.withOpacity(0.12);
    return AppColors.forestLight.withOpacity(0.12);
  }

  Color get _iconColor {
    if (stat.type == 'urgent') return AppColors.umber;
    if (stat.type == 'inbox') return AppColors.goldDark;
    return AppColors.forest;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 135,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withOpacity(0.10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            Text(
              stat.value,
              style: const TextStyle(
                fontSize: 34,
                height: 1,
                fontWeight: FontWeight.w400,
                color: AppColors.forest,
              ),
            ),
            const Spacer(),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    stat.title,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.25,
                      fontWeight: FontWeight.w400,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    stat.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.2,
                      fontWeight: FontWeight.w400,
                      color: AppColors.goldDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _icon,
                size: 21,
                color: _iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}