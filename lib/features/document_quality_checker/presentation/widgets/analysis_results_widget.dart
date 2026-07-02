import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../domain/models/analysis_result.dart';

/// Displays detailed analysis results: Blur, Resolution, Brightness.
class AnalysisResultsWidget extends StatelessWidget {
  final AnalysisResult result;

  const AnalysisResultsWidget({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gold.withOpacity(0.20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تفاصيل التحليل',
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.charcoalDark),
            ),
            const SizedBox(height: 20),

            // 1. Blur Detection
            _AnalysisCheck(
              icon: LucideIcons.focus,
              title: 'فحص الوضوح',
              subtitle: _blurSubtitle,
              score: result.blurScore,
              color: _blurColor,
              statusLabel: _blurLabel,
            ),
            const SizedBox(height: 16),

            // 2. Resolution Check
            _AnalysisCheck(
              icon: LucideIcons.maximize2,
              title: 'فحص الدقة',
              subtitle: result.resolutionText,
              score: _resolutionScore,
              color: _resColor,
              statusLabel: _resLabel,
            ),
            const SizedBox(height: 16),

            // 3. Brightness Check
            _AnalysisCheck(
              icon: LucideIcons.sun,
              title: 'فحص الإضاءة',
              subtitle: _brightnessSubtitle,
              score: result.brightnessScore,
              color: _brightnessColor,
              statusLabel: _brightnessLabel,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Blur ───────────────────────────────────────────────────
  String get _blurSubtitle => '${result.blurScore.round()} / 100';

  String get _blurLabel {
    switch (result.blurLevel) {
      case BlurLevel.clear:
        return 'واضحة';
      case BlurLevel.acceptable:
        return 'مقبولة';
      case BlurLevel.blurry:
        return 'مغبشة';
    }
  }

  Color get _blurColor {
    switch (result.blurLevel) {
      case BlurLevel.clear:
        return const Color(0xFF2E7D32);
      case BlurLevel.acceptable:
        return const Color(0xFFE6A817);
      case BlurLevel.blurry:
        return AppColors.umber;
    }
  }

  // ─── Resolution ─────────────────────────────────────────────
  double get _resolutionScore {
    final w = result.resolutionWidth / AnalysisResult.minWidth;
    final h = result.resolutionHeight / AnalysisResult.minHeight;
    return ((w + h) / 2 * 100).clamp(0, 100);
  }

  String get _resLabel {
    switch (result.resolutionStatus) {
      case ResolutionStatus.suitable:
        return 'مناسبة';
      case ResolutionStatus.lowResolution:
        return 'منخفضة';
    }
  }

  Color get _resColor {
    switch (result.resolutionStatus) {
      case ResolutionStatus.suitable:
        return const Color(0xFF2E7D32);
      case ResolutionStatus.lowResolution:
        return AppColors.umber;
    }
  }

  // ─── Brightness ─────────────────────────────────────────────
  String get _brightnessSubtitle {
    return '${result.brightnessScore.round()} / 100';
  }

  String get _brightnessLabel {
    switch (result.brightnessLevel) {
      case BrightnessLevel.tooDark:
        return 'داكنة جدًا';
      case BrightnessLevel.balanced:
        return 'متوازنة';
      case BrightnessLevel.tooBright:
        return 'ساطعة جدًا';
    }
  }

  Color get _brightnessColor {
    switch (result.brightnessLevel) {
      case BrightnessLevel.tooDark:
        return AppColors.umber;
      case BrightnessLevel.balanced:
        return const Color(0xFF2E7D32);
      case BrightnessLevel.tooBright:
        return const Color(0xFFE6A817);
    }
  }
}

// ─── Reusable analysis check row ──────────────────────────────────

class _AnalysisCheck extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double score;
  final Color color;
  final String statusLabel;

  const _AnalysisCheck({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.score,
    required this.color,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            textDirection: TextDirection.ltr,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: AppTextStyles.semiBold,
                        color: AppColors.charcoalDark,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.charcoal.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusLabel,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: AppTextStyles.semiBold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: score.clamp(0, 100) / 100),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: color.withOpacity(0.10),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
