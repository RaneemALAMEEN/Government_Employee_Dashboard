import '../../../../shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../domain/entities/internal_category_entity.dart';

class InternalCategoriesSection extends StatelessWidget {
  final List<InternalCategoryEntity> categories;
  final int selectedCategoryId;
  final ValueChanged<int> onSelected;

  const InternalCategoriesSection({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final total = categories.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
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
      child: Directionality(
        textDirection: TextDirection.rtl, // توحيد التوجيه للمكون بالكامل
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // يبدأ من اليمين بسبب RTL
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'تصنيفات المعاملات',
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: AppTextStyles.medium, color: AppColors.goldDark),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.start,
              children: [
                _CategoryChip(
                  title: 'الكل',
                  count: total,
                  icon: Icons.apps_outlined,
                  isSelected: selectedCategoryId == -1,
                  onTap: () => onSelected(-1),
                ),
                ...categories.map(
                  (category) => _CategoryChip(
                    title: category.name,
                    count:
                        1, // يمكنك استبدالها بعدد المعاملات الفعلي لكل قسم مستقبلاً
                    icon: _iconForCategory(category.name),
                    isSelected: selectedCategoryId == category.id,
                    onTap: () => onSelected(category.id),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForCategory(String name) {
    if (name.contains('طالب')) return Icons.school_outlined;
    if (name.contains('البشرية')) return Icons.groups_outlined;
    if (name.contains('مدرس')) return Icons.menu_book_outlined;
    if (name.contains('مراسلات')) return Icons.send_outlined;
    if (name.contains('إحصائيات')) return Icons.bar_chart_outlined;
    if (name.contains('صيانة')) return Icons.apartment_outlined;
    if (name.contains('تقني')) return Icons.computer_outlined;
    return Icons.category_outlined;
  }
}

class _CategoryChip extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.title,
    required this.count,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 44,
        // تم استخدام حيازة مرنة (Constraints) ليعطي حرية تمدد وانكماش للشريحة
        constraints: const BoxConstraints(
          minWidth: 80,
          maxWidth:
              220, // يمنع الشريحة الواحدة من تشويه المظهر إذا كان النص طويلاً جداً
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.forest : AppColors.goldLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.white : AppColors.charcoalDark,
            ),
            const SizedBox(width: 8),
            // تغليف النص بـ Flexible لمنع الـ Overflow وتفعيل التقرير النقاطي عند الضيق
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: AppTextStyles.semiBold, color: isSelected ? AppColors.white : AppColors.charcoalDark),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 24,
              height: 24,
              // لمنع الدائرة من الانكماش وتشويه شكل الرقم
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.white.withOpacity(0.18)
                    : AppColors.charcoal.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Text(
                count.toString(),
                style: AppTextStyles.labelLarge.copyWith(fontWeight: AppTextStyles.bold, color: isSelected ? AppColors.white : AppColors.goldDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
