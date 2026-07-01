import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../domain/models/analysis_result.dart';

/// Verdict card (green / yellow / red) with action button and rejection reasons.
class VerdictWidget extends StatelessWidget {
  final QualityVerdict verdict;
  final List<String> reasons;
  final VoidCallback onAction;

  const VerdictWidget({
    super.key,
    required this.verdict,
    required this.reasons,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 200),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _accentColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, size: 28, color: _accentColor),
            ),
            const SizedBox(height: 14),

            // Main message
            Text(
              _message,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium.copyWith(
                color: _accentColor,
                fontWeight: AppTextStyles.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: _accentColor.withOpacity(0.75),
              ),
            ),

            // Reasons
            if (reasons.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.60),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الأسباب:',
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: AppTextStyles.semiBold,
                        color: _accentColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...reasons.map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(LucideIcons.dot,
                                    size: 16, color: _accentColor),
                                const SizedBox(width: 4),
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
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Action button
            SizedBox(
              width: double.infinity,
              child: Material(
                color: _accentColor,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: onAction,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      _buttonLabel,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: Colors.white,
                        fontWeight: AppTextStyles.semiBold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Theming per verdict ─────────────────────────────────────

  Color get _accentColor {
    switch (verdict) {
      case QualityVerdict.accepted:
        return const Color(0xFF2E7D32);
      case QualityVerdict.warning:
        return const Color(0xFFB8860B);
      case QualityVerdict.rejected:
        return AppColors.umber;
    }
  }

  Color get _bgColor {
    switch (verdict) {
      case QualityVerdict.accepted:
        return const Color(0xFFF1F8E9);
      case QualityVerdict.warning:
        return const Color(0xFFFFF8E1);
      case QualityVerdict.rejected:
        return const Color(0xFFFCE4EC);
    }
  }

  Color get _borderColor {
    switch (verdict) {
      case QualityVerdict.accepted:
        return const Color(0xFFA5D6A7);
      case QualityVerdict.warning:
        return const Color(0xFFFFE082);
      case QualityVerdict.rejected:
        return const Color(0xFFEF9A9A);
    }
  }

  IconData get _icon {
    switch (verdict) {
      case QualityVerdict.accepted:
        return LucideIcons.checkCircle2;
      case QualityVerdict.warning:
        return LucideIcons.alertTriangle;
      case QualityVerdict.rejected:
        return LucideIcons.xCircle;
    }
  }

  String get _message {
    switch (verdict) {
      case QualityVerdict.accepted:
        return '✓ الوثيقة مناسبة للرفع';
      case QualityVerdict.warning:
        return '⚠ الوثيقة مقبولة لكن يفضل إعادة التصوير';
      case QualityVerdict.rejected:
        return '✕ الصورة غير واضحة';
    }
  }

  String get _subtitle {
    switch (verdict) {
      case QualityVerdict.accepted:
        return 'الوثيقة جاهزة للإرسال';
      case QualityVerdict.warning:
        return 'يمكنك المتابعة أو إعادة التصوير للحصول على نتيجة أفضل';
      case QualityVerdict.rejected:
        return 'يرجى إعادة تصوير الوثيقة والمحاولة مجددًا';
    }
  }

  String get _buttonLabel {
    switch (verdict) {
      case QualityVerdict.accepted:
        return 'متابعة';
      case QualityVerdict.warning:
        return 'رفع على أي حال';
      case QualityVerdict.rejected:
        return 'إعادة المحاولة';
    }
  }
}
