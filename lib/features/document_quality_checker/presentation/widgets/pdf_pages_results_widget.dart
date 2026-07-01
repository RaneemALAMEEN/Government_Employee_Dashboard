import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:animate_do/animate_do.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../domain/models/analysis_result.dart';

/// Displays per-page results for PDF analysis + overall score.
class PdfPagesResultsWidget extends StatelessWidget {
  final PdfAnalysisResult pdfResult;

  const PdfPagesResultsWidget({super.key, required this.pdfResult});

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
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Icon(LucideIcons.fileStack, size: 18, color: AppColors.forest),
                const SizedBox(width: 8),
                Text(
                  'نتائج صفحات الوثيقة',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.charcoalDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Per-page scores
            ...List.generate(pdfResult.pageResults.length, (i) {
              final pageResult = pdfResult.pageResults[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _PageScoreRow(
                  pageNumber: i + 1,
                  result: pageResult,
                ),
              );
            }),

            // Overall
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: _overallColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _overallColor.withOpacity(0.25)),
              ),
              child: Row(
                textDirection: TextDirection.ltr,
                children: [
                  Icon(LucideIcons.barChart3, size: 18, color: _overallColor),
                  const SizedBox(width: 10),
                  Text(
                    'الإجمالي',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: AppTextStyles.bold,
                      color: _overallColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${pdfResult.overallScore.round()}%',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: _overallColor,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),

            // PDF-specific warnings
            if (pdfResult.reasons.isNotEmpty) ...[
              const SizedBox(height: 14),
              ...pdfResult.reasons.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Row(
                        children: [
                          Icon(
                            pdfResult.verdict == QualityVerdict.rejected
                                ? LucideIcons.xCircle
                                : LucideIcons.alertTriangle,
                            size: 14,
                            color: pdfResult.verdict == QualityVerdict.rejected
                                ? AppColors.umber
                                : const Color(0xFFB8860B),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              r,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.charcoalDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Color get _overallColor {
    switch (pdfResult.verdict) {
      case QualityVerdict.accepted:
        return const Color(0xFF2E7D32);
      case QualityVerdict.warning:
        return const Color(0xFFB8860B);
      case QualityVerdict.rejected:
        return AppColors.umber;
    }
  }
}

class _PageScoreRow extends StatelessWidget {
  final int pageNumber;
  final AnalysisResult result;

  const _PageScoreRow({
    required this.pageNumber,
    required this.result,
  });

  Color get _color {
    if (result.finalScore >= 80) return const Color(0xFF2E7D32);
    if (result.finalScore >= 60) return const Color(0xFFB8860B);
    return AppColors.umber;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.goldLight.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.forest.withOpacity(0.10),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'صفحة $pageNumber',
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: AppTextStyles.semiBold,
                color: AppColors.forest,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Mini details
          Expanded(
            child: Row(
              textDirection: TextDirection.ltr,
              children: [
                _MiniStat(icon: LucideIcons.focus, label: 'وضوح', value: '${result.blurScore.round()}'),
                const SizedBox(width: 10),
                _MiniStat(icon: LucideIcons.maximize2, label: 'دقة', value: result.resolutionText),
                const SizedBox(width: 10),
                _MiniStat(icon: LucideIcons.sun, label: 'إضاءة', value: '${result.brightnessScore.round()}'),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${result.finalScore.round()}%',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: AppTextStyles.bold,
                color: _color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: AppColors.charcoal.withOpacity(0.5)),
        const SizedBox(width: 3),
        Text(
          value,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.charcoal.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
