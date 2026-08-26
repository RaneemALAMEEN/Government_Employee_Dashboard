import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppEmptySearchState extends StatelessWidget {
  final String title;
  final String? description;
  final String svgPath;
  final double svgWidth;
  final double svgHeight;
  final Widget? action;
  final EdgeInsetsGeometry padding;
  final bool isCard;
  final double maxWidth;

  const AppEmptySearchState({
    super.key,
    this.title = 'لا توجد نتائج تطابق بحثك',
    this.description = 'تأكد من كتابة الكلمات بشكل صحيح أو جرّب البحث بكلمات أخرى.',
    this.svgPath = 'assets/vectors/empty search.svg',
    this.svgWidth = 140,
    this.svgHeight = 140,
    this.action,
    this.padding = const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
    this.isCard = true,
    this.maxWidth = 480,
  });

  @override
  Widget build(BuildContext context) {
    final innerContent = FadeIn(
      duration: const Duration(milliseconds: 350),
      child: ZoomIn(
        duration: const Duration(milliseconds: 400),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                svgPath,
                width: svgWidth,
                height: svgHeight,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoalDark,
                ),
              ),
              if (description != null && description!.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  description!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.charcoal.withValues(alpha: 0.65),
                    height: 1.5,
                  ),
                ),
              ],
              if (action != null) ...[
                const SizedBox(height: 20),
                action!,
              ],
            ],
          ),
        ),
      ),
    );

    if (!isCard) {
      return Padding(
        padding: padding,
        child: Center(child: innerContent),
      );
    }

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: innerContent,
    );
  }
}
