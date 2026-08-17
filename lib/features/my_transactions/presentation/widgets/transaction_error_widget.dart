import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

class TransactionErrorWidget extends StatelessWidget {
  final String errorCode;
  final String title;
  final String message;
  final List<String> suggestions;
  final VoidCallback onBack;
  final VoidCallback? onRetry;

  const TransactionErrorWidget({
    super.key,
    required this.errorCode,
    required this.title,
    required this.message,
    required this.suggestions,
    required this.onBack,
    this.onRetry,
  });

  IconData _getIcon() {
    switch (errorCode) {
      case 'VERSION_CONFLICT':
        return LucideIcons.gitBranch;
      case 'TASK_NOT_FOUND':
        return LucideIcons.searchX;
      case 'SIGNING_ERROR':
        return LucideIcons.keyRound;
      case 'LOCK_ERROR':
        return LucideIcons.lock;
      default:
        return LucideIcons.alertTriangle;
    }
  }

  Color _getColor() {
    switch (errorCode) {
      case 'VERSION_CONFLICT':
        return AppColors.umber;
      case 'TASK_NOT_FOUND':
        return AppColors.umberLight;
      case 'SIGNING_ERROR':
        return AppColors.umber;
      case 'LOCK_ERROR':
        return AppColors.umberDark;
      default:
        return AppColors.umber;
    }
  }


  String _getErrorLabel() {
    switch (errorCode) {
      case 'VERSION_CONFLICT':
        return 'تعارض إصدار';
      case 'TASK_NOT_FOUND':
        return 'مهمة غير موجودة';
      case 'SIGNING_ERROR':
        return 'خطأ توقيع';
      case 'LOCK_ERROR':
        return 'معاملة مقفلة';
      default:
        return 'خطأ غير معروف';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final icon = _getIcon();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: FadeInUp(
            duration: const Duration(milliseconds: 500),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 640),
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: color.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.08),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Icon
                  ZoomIn(
                    duration: const Duration(milliseconds: 600),
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.18),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(icon, color: color, size: 46),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Error Code Badge
                  FadeInDown(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 400),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: color.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        _getErrorLabel(),
                        style: AppTextStyles.labelMedium.copyWith(
                          color: color,
                          fontWeight: AppTextStyles.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.displayMedium.copyWith(
                      color: color,
                      fontWeight: AppTextStyles.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Description
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.charcoal.withValues(alpha: 0.7),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Suggestions Card
                  if (suggestions.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.goldLight.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                LucideIcons.lightbulb,
                                size: 18,
                                color: AppColors.goldDark,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'ماذا يمكنك أن تفعل؟',
                                style: AppTextStyles.labelLarge.copyWith(
                                  fontWeight: AppTextStyles.bold,
                                  color: AppColors.charcoalDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ...suggestions.asMap().entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 3),
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${entry.key + 1}',
                                        style:
                                            AppTextStyles.labelSmall.copyWith(
                                          color: color,
                                          fontWeight: AppTextStyles.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      entry.value,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.charcoal
                                            .withValues(alpha: 0.85),
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Action Buttons
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 460;

                      final backButton = OutlinedButton.icon(
                        onPressed: onBack,
                        icon: const Icon(LucideIcons.arrowRight, size: 18),
                        label: const Text('عودة إلى معاملاتي'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.charcoalDark,
                          side: BorderSide(
                            color: AppColors.charcoal.withValues(alpha: 0.3),
                            width: 1.2,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: AppTextStyles.labelLarge.copyWith(
                            fontWeight: AppTextStyles.semiBold,
                          ),
                        ),
                      );

                      final retryButton = onRetry != null
                          ? ElevatedButton.icon(
                              onPressed: onRetry,
                              icon: const Icon(LucideIcons.refreshCw, size: 18),
                              label: const Text('إعادة المحاولة'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: color,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                elevation: 2,
                                shadowColor: color.withValues(alpha: 0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: AppTextStyles.labelLarge.copyWith(
                                  fontWeight: AppTextStyles.bold,
                                ),
                              ),
                            )
                          : null;

                      if (isNarrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (retryButton != null) ...[
                              retryButton,
                              const SizedBox(height: 12),
                            ],
                            backButton,
                          ],
                        );
                      }

                      if (retryButton == null) {
                        return SizedBox(
                          width: double.infinity,
                          child: backButton,
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: backButton),
                          const SizedBox(width: 16),
                          Expanded(child: retryButton),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
