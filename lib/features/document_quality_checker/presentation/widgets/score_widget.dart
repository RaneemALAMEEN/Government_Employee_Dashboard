import 'dart:math';

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../domain/models/analysis_result.dart';

/// Large animated circular progress widget showing the final document quality score.
class ScoreWidget extends StatelessWidget {
  final double score;
  final QualityVerdict verdict;

  const ScoreWidget({
    super.key,
    required this.score,
    required this.verdict,
  });

  Color get _color {
    switch (verdict) {
      case QualityVerdict.accepted:
        return const Color(0xFF2E7D32); // green
      case QualityVerdict.warning:
        return const Color(0xFFE6A817); // amber
      case QualityVerdict.rejected:
        return AppColors.umber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: const Duration(milliseconds: 500),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gold.withOpacity(0.20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'نتيجة جودة الوثيقة',
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.charcoalDark),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 150,
              height: 150,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: score / 100),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return CustomPaint(
                    painter: _CircleScorePainter(
                      progress: value,
                      color: _color,
                    ),
                    child: Center(
                      child: Text(
                        '${(value * 100).round()}%',
                        style: AppTextStyles.displayLarge.copyWith(
                          fontSize: 36,
                          fontWeight: AppTextStyles.bold,
                          color: _color,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _verdictLabel,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: AppTextStyles.semiBold,
                  color: _color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _verdictLabel {
    switch (verdict) {
      case QualityVerdict.accepted:
        return '✓ جودة ممتازة';
      case QualityVerdict.warning:
        return '⚠ جودة مقبولة';
      case QualityVerdict.rejected:
        return '✕ جودة ضعيفة';
    }
  }
}

// ─── Custom Painter ───────────────────────────────────────────────

class _CircleScorePainter extends CustomPainter {
  final double progress; // 0..1
  final Color color;

  _CircleScorePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Background circle
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withOpacity(0.10)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10,
    );

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_CircleScorePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
