import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../domain/entities/self_card_entity.dart';

class SelfCardJobInfoCard extends StatelessWidget {
  final SelfCardEntity selfCard;

  const SelfCardJobInfoCard({
    super.key,
    required this.selfCard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.forest.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              border: Border(
                bottom: BorderSide(color: AppColors.gold.withValues(alpha: 0.25)),
              ),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                const Icon(LucideIcons.briefcase, color: AppColors.forest, size: 20),
                const SizedBox(width: 10),
                Text(
                  'المعلومات الوظيفية والشهادات',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.forest,
                  ),
                ),
              ],
            ),
          ),

          // Content Grid
          Padding(
            padding: const EdgeInsets.all(20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 650;
                final crossAxisCount = isWide ? 3 : 2;

                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isWide ? 2.8 : 2.2,
                  children: [
                    _InfoTile(
                      icon: LucideIcons.badgeCheck,
                      label: 'الرقم الذاتي',
                      value: selfCard.selfNumber ?? '-',
                    ),
                    _InfoTile(
                      icon: LucideIcons.creditCard,
                      label: 'الرقم الوطني',
                      value: selfCard.nationalId ?? '-',
                    ),
                    _InfoTile(
                      icon: LucideIcons.shield,
                      label: 'رقم التأمين',
                      value: selfCard.insuranceNumber ?? '-',
                    ),
                    _InfoTile(
                      icon: LucideIcons.graduationCap,
                      label: 'الشهادة العلمية',
                      value: selfCard.educationDegree ?? '-',
                    ),
                    _InfoTile(
                      icon: LucideIcons.languages,
                      label: 'اللغة الأجنبية',
                      value: selfCard.foreignLanguage ?? '-',
                    ),
                    _InfoTile(
                      icon: LucideIcons.home,
                      label: 'مكان الإقامة الحالي',
                      value: selfCard.currentResidence ?? '-',
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.goldLight.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(icon, size: 18, color: AppColors.forestLight),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.charcoal.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoalDark,
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
