import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../domain/entities/self_card_entity.dart';

class SelfCardPersonalInfoCard extends StatelessWidget {
  final SelfCardEntity selfCard;

  const SelfCardPersonalInfoCard({
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
                const Icon(LucideIcons.user, color: AppColors.forest, size: 20),
                const SizedBox(width: 10),
                Text(
                  'المعلومات الشخصية',
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
                      icon: LucideIcons.user,
                      label: 'الاسم الكامل',
                      value: selfCard.fullName,
                    ),
                    _InfoTile(
                      icon: LucideIcons.users,
                      label: 'اسم الأب',
                      value: selfCard.fatherName ?? '-',
                    ),
                    _InfoTile(
                      icon: LucideIcons.heartHandshake,
                      label: 'اسم الأم',
                      value: selfCard.motherName ?? '-',
                    ),
                    _InfoTile(
                      icon: LucideIcons.calendar,
                      label: 'تاريخ الميلاد',
                      value: selfCard.birthDate ?? '-',
                    ),
                    _InfoTile(
                      icon: LucideIcons.mapPin,
                      label: 'مكان الميلاد',
                      value: selfCard.birthPlace ?? '-',
                    ),
                    _InfoTile(
                      icon: LucideIcons.venetianMask,
                      label: 'الجنس',
                      value: _formatGender(selfCard.gender),
                    ),
                    _InfoTile(
                      icon: LucideIcons.globe,
                      label: 'الجنسية',
                      value: selfCard.nationality ?? 'سوري',
                    ),
                    _InfoTile(
                      icon: LucideIcons.bookmark,
                      label: 'مكان السجل',
                      value: selfCard.registryPlace ?? '-',
                    ),
                    _InfoTile(
                      icon: LucideIcons.hash,
                      label: 'رقم السجل',
                      value: selfCard.registryNumber ?? '-',
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

  static String _formatGender(String? gender) {
    if (gender == null) return '-';
    final g = gender.toLowerCase().trim();
    if (g == 'male' || g == 'ذكر') return 'ذكر';
    if (g == 'female' || g == 'أنثى') return 'أنثى';
    return gender;
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
