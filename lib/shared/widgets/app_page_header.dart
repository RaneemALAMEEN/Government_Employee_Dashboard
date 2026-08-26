import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// ترويسة موحدة لصفحات النظام تطابق تماماً أسلوب صفحة معاملاتي:
/// - عنوان رئيسي بستايل [AppTextStyles.displayMedium]
/// - مسافة 6 بكسل
/// - جملة توضيحية بستايل [AppTextStyles.bodySmall] ولون [AppColors.goldDark]
class AppPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? backButton;
  final EdgeInsetsGeometry? padding;
  final CrossAxisAlignment crossAxisAlignment;

  const AppPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.backButton,
    this.padding,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final titleColumn = Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (backButton != null) ...[
          backButton!,
          const SizedBox(height: 16),
        ],
        Text(
          title,
          textAlign: TextAlign.right,
          style: AppTextStyles.displayMedium,
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            textAlign: TextAlign.right,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.goldDark),
          ),
        ],
      ],
    );

    final content = trailing == null
        ? titleColumn
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: titleColumn),
              const SizedBox(width: 16),
              trailing!,
            ],
          );

    if (padding != null) {
      return Padding(
        padding: padding!,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: content,
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: content,
    );
  }
}
