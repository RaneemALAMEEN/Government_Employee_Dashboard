import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

class TransactionSignedSuccessWidget extends StatelessWidget {
  final String taskId;
  final String transactionId;
  final String message;
  final bool isApproved;
  final VoidCallback onBack;
  final VoidCallback onViewCompleted;

  const TransactionSignedSuccessWidget({
    super.key,
    required this.taskId,
    required this.transactionId,
    required this.message,
    this.isApproved = true,
    required this.onBack,
    required this.onViewCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isApproved ? AppColors.forest : AppColors.error;
    final iconData = isApproved ? LucideIcons.circleCheck : LucideIcons.circleX;
    final defaultTitle = isApproved ? 'تم توقيع المعاملة بنجاح' : 'تم رفض المعاملة';
    final subtitleText = isApproved
        ? 'تمت عملية التوقيع الإلكتروني بنجاح واكتملت مرحلة المعاملة، وتثبيت التوقيع في السجل الحكومي.'
        : 'تم تسجيل قرار رفض المعاملة بنجاح، وتحديث حالة الطلب في السجل الحكومي.';
    final viewButtonText = isApproved
        ? 'عرض تفاصيل المعاملة المنجزة'
        : 'عرض تفاصيل المعاملة المرفوضة';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: FadeInUp(
          duration: const Duration(milliseconds: 500),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 620),
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isApproved
                    ? AppColors.gold.withValues(alpha: 0.35)
                    : AppColors.error.withValues(alpha: 0.25),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isApproved
                      ? AppColors.forest.withValues(alpha: 0.08)
                      : AppColors.error.withValues(alpha: 0.08),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Icon Badge
                ZoomIn(
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      iconData,
                      color: primaryColor,
                      size: 52,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Success / Rejection Title
                Text(
                  message.isNotEmpty ? message : defaultTitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.displayMedium.copyWith(
                    color: primaryColor,
                    fontWeight: AppTextStyles.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 14),

                // Subtitle Description
                Text(
                  subtitleText,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.charcoal.withValues(alpha: 0.8),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),

                // Transaction Number Info Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isApproved
                        ? AppColors.goldLight.withValues(alpha: 0.45)
                        : AppColors.error.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isApproved
                          ? AppColors.gold.withValues(alpha: 0.3)
                          : AppColors.error.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.fileText,
                        size: 20,
                        color: isApproved ? AppColors.goldDark : AppColors.error,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'رقم المعاملة: $transactionId',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.charcoalDark,
                          fontWeight: AppTextStyles.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

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

                    final viewButton = ElevatedButton.icon(
                      onPressed: onViewCompleted,
                      icon: const Icon(LucideIcons.eye, size: 18),
                      label: Text(viewButtonText),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        elevation: 2,
                        shadowColor: primaryColor.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: AppTextStyles.labelLarge.copyWith(
                          fontWeight: AppTextStyles.bold,
                        ),
                      ),
                    );

                    if (isNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          viewButton,
                          const SizedBox(height: 12),
                          backButton,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: backButton),
                        const SizedBox(width: 16),
                        Expanded(child: viewButton),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
