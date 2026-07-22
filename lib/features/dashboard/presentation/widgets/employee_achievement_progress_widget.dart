import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

/// A professional, engaging widget that displays the employee's daily
/// achievement progress based on active and completed transactions.
class EmployeeAchievementProgressWidget extends StatelessWidget {
  final int pendingCount;
  final int inProgressCount;
  final int completedCount;

  const EmployeeAchievementProgressWidget({
    Key? key,
    required this.pendingCount,
    required this.inProgressCount,
    required this.completedCount,
  }) : super(key: key);

  /// The total workload pool is dynamically determined by the sum of transactions.
  int get totalPool => pendingCount + inProgressCount + completedCount;

  /// The progress percentage/bar increases specifically when a transaction transitions
  /// to a "Completed/Signed" state.
  double get progress => totalPool == 0 ? 0.0 : completedCount / totalPool;

  @override
  Widget build(BuildContext context) {
    // Determine the color theme based on completion status
    final isFullyCompleted = totalPool > 0 && progress >= 1.0;
    final progressColor = isFullyCompleted ? AppColors.forest : AppColors.forestLight;
    final titleColor = isFullyCompleted ? AppColors.forest : AppColors.charcoalDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFullyCompleted
              ? AppColors.forest.withOpacity(0.3)
              : AppColors.gold.withOpacity(0.2),
          width: isFullyCompleted ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isFullyCompleted
                ? AppColors.forest.withOpacity(0.08)
                : AppColors.charcoal.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          // Left Side: Texts and motivations
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isFullyCompleted
                            ? AppColors.forest.withOpacity(0.1)
                            : AppColors.goldLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isFullyCompleted ? LucideIcons.checkCircle : LucideIcons.target,
                        color: isFullyCompleted ? AppColors.forest : AppColors.goldDark,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'مستوى الإنجاز اليومي',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  totalPool == 0
                      ? 'لا توجد معاملات قيد الانتظار حالياً'
                      : 'تم إنجاز $completedCount من أصل $totalPool معاملة',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.charcoal,
                    height: 1.4,
                  ),
                ),
                if (totalPool > 0 && !isFullyCompleted) ...[
                  const SizedBox(height: 6),
                  Text(
                    'بانتظار إنجاز ${pendingCount + inProgressCount} معاملة متبقية',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.umberLight,
                    ),
                  ),
                ] else if (isFullyCompleted) ...[
                  const SizedBox(height: 6),
                  Text(
                    'أداء ممتاز! لقد تم إنهاء جميع المهام.',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.forest,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 24),

          // Right Side: Animated Circular Progress Ring
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: progress),
            duration: const Duration(milliseconds: 1400),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              final percentage = (value * 100).toInt();
              return SizedBox(
                width: 84,
                height: 84,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 84,
                      height: 84,
                      child: CustomPaint(
                        painter: _ProgressRingPainter(
                          progress: value,
                          trackColor: AppColors.goldLight.withOpacity(0.6),
                          progressColor: progressColor,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$percentage%',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: progressColor,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// A custom painter to draw a smooth, rounded progress ring.
class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  _ProgressRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 9.0;
    final radius = math.min(size.width / 2, size.height / 2) - (strokeWidth / 2);

    // Draw track (background ring)
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    // Draw progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      const startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}
