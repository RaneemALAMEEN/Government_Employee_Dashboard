import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../shared/theme/app_colors.dart';
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
        return LucideIcons.checkCircle;
      case 'urgent':
        return LucideIcons.zap;
      case 'sign':
        return LucideIcons.edit;
      default:
        return LucideIcons.inbox;
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
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
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
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
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
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.title,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
          const SizedBox(width: 10),
          Flexible(
            flex: 0,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                stat.value,
                style: const TextStyle(
                  fontSize: 34,
                  height: 1,
                  fontWeight: FontWeight.w400,
                  color: AppColors.forest,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
