import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

class TransactionUploadProgressOverlay extends StatelessWidget {
  final String? message;
  final String? stage; // 'preparing', 'uploading', 'signing', 'submitting'
  final String? currentFileName;
  final int? currentFileIndex;
  final int? totalFiles;
  final double? progress;

  const TransactionUploadProgressOverlay({
    Key? key,
    this.message,
    this.stage,
    this.currentFileName,
    this.currentFileIndex,
    this.totalFiles,
    this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentStage = stage ?? _inferStage(message);
    final isUploadingStage = currentStage == 'uploading';
    final isSigningStage = currentStage == 'signing';
    final isSubmittingStage = currentStage == 'submitting';

    final effectiveMessage = message?.isNotEmpty == true
        ? message!
        : (isUploadingStage
            ? 'جاري رفع الملفات إلى السيرفر...'
            : isSigningStage
                ? 'جاري توقيع المعاملة رقمياً...'
                : 'جاري معالجة وتجهيز المعاملة...');

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        children: [
          // Frosted Glass Blur Backdrop
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 250),
              builder: (context, value, child) {
                return BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 4.0 * value,
                    sigmaY: 4.0 * value,
                  ),
                  child: Container(
                    color: Colors.black.withOpacity(0.45 * value),
                  ),
                );
              },
            ),
          ),

          // Central Progress Card
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: FadeInUp(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.forest.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.forest.withOpacity(0.18),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Animated Upload Icon Header
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer pulsing glow
                            Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (isUploadingStage
                                        ? AppColors.forest
                                        : AppColors.gold)
                                    .withOpacity(0.12),
                              ),
                            ),
                            // Inner circle
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: isUploadingStage
                                      ? [
                                          AppColors.forest,
                                          const Color(0xFF163E34),
                                        ]
                                      : isSigningStage
                                          ? [
                                              const Color(0xFFB38600),
                                              AppColors.goldDark,
                                            ]
                                          : [
                                              AppColors.forest,
                                              AppColors.forestLight,
                                            ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isUploadingStage
                                            ? AppColors.forest
                                            : AppColors.gold)
                                        .withOpacity(0.35),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                isUploadingStage
                                    ? LucideIcons.uploadCloud
                                    : isSigningStage
                                        ? LucideIcons.shieldCheck
                                        : LucideIcons.loader,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Card Title
                      Text(
                        isUploadingStage
                            ? 'جاري رفع المرفقات إلى السيرفر'
                            : isSigningStage
                                ? 'جاري التوقيع الرقمي والاعتماد'
                                : 'جاري معالجة المعاملة',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontWeight: AppTextStyles.bold,
                          color: AppColors.charcoalDark,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Detailed status message
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.forestLight.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.forest.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.forest,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                effectiveMessage,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: AppTextStyles.semiBold,
                                  color: AppColors.forest,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 8,
                          color: AppColors.goldLight.withOpacity(0.5),
                          child: progress != null
                              ? LinearProgressIndicator(
                                  value: progress!.clamp(0.05, 1.0),
                                  backgroundColor: Colors.transparent,
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.forest,
                                  ),
                                )
                              : const LinearProgressIndicator(
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.forest,
                                  ),
                                ),
                        ),
                      ),

                      // File Count Badge (if multiple files)
                      if (totalFiles != null && totalFiles! > 0) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'المرفقات المرفوعة:',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.charcoal.withOpacity(0.7),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${currentFileIndex ?? 0} / $totalFiles',
                                style: AppTextStyles.labelSmall.copyWith(
                                  fontWeight: AppTextStyles.bold,
                                  color: AppColors.charcoalDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 20),

                      // Steps Indicator
                      _buildStepsTimeline(
                        isUploadingStage: isUploadingStage,
                        isSigningStage: isSigningStage,
                        isSubmittingStage: isSubmittingStage,
                      ),
                      const SizedBox(height: 20),

                      // Informational note
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              LucideIcons.info,
                              size: 16,
                              color: AppColors.charcoal.withOpacity(0.6),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'يرجى الانتظار دون إغلاق الصفحة أو تحديثها حتى تكتمل عملية الرفع والاعتماد بأمان.',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.charcoal.withOpacity(0.75),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsTimeline({
    required bool isUploadingStage,
    required bool isSigningStage,
    required bool isSubmittingStage,
  }) {
    int activeStep = 1;
    if (isUploadingStage) {
      activeStep = 2;
    } else if (isSigningStage) {
      activeStep = 3;
    } else if (isSubmittingStage) {
      activeStep = 4;
    }

    return Column(
      children: [
        _buildStepItem(
          stepNumber: 1,
          title: 'فحص وتجهيز البيانات',
          isDone: activeStep > 1,
          isActive: activeStep == 1,
        ),
        _buildStepDivider(isDone: activeStep > 1),
        _buildStepItem(
          stepNumber: 2,
          title: 'رفع المرفقات إلى السيرفر',
          isDone: activeStep > 2,
          isActive: activeStep == 2,
        ),
        _buildStepDivider(isDone: activeStep > 2),
        _buildStepItem(
          stepNumber: 3,
          title: 'التوقيع الرقمي والاعتماد',
          isDone: activeStep > 3,
          isActive: activeStep >= 3,
        ),
      ],
    );
  }

  Widget _buildStepItem({
    required int stepNumber,
    required String title,
    required bool isDone,
    required bool isActive,
  }) {
    Color iconBg;
    Color iconFg;
    Color textColor;

    if (isDone) {
      iconBg = AppColors.forest;
      iconFg = Colors.white;
      textColor = AppColors.forest;
    } else if (isActive) {
      iconBg = AppColors.gold;
      iconFg = AppColors.charcoalDark;
      textColor = AppColors.charcoalDark;
    } else {
      iconBg = Colors.grey.shade200;
      iconFg = Colors.grey.shade500;
      textColor = Colors.grey.shade500;
    }

    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: iconBg,
          ),
          child: Center(
            child: isDone
                ? const Icon(LucideIcons.check, size: 14, color: Colors.white)
                : isActive
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.charcoalDark,
                        ),
                      )
                    : Text(
                        '$stepNumber',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: iconFg,
                        ),
                      ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              fontWeight:
                  isActive ? AppTextStyles.bold : AppTextStyles.medium,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider({required bool isDone}) {
    return Padding(
      padding: const EdgeInsets.only(right: 11, top: 2, bottom: 2),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: 2,
          height: 12,
          color: isDone ? AppColors.forest : Colors.grey.shade200,
        ),
      ),
    );
  }

  String _inferStage(String? msg) {
    if (msg == null || msg.isEmpty) return 'preparing';
    if (msg.contains('رفع') || msg.contains('upload') || msg.contains('ملف')) {
      return 'uploading';
    }
    if (msg.contains('توقيع') || msg.contains('sign') || msg.contains('USB')) {
      return 'signing';
    }
    if (msg.contains('إرسال') || msg.contains('اعتماد')) {
      return 'submitting';
    }
    return 'preparing';
  }
}
