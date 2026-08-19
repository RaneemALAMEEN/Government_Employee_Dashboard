import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../../../shared/theme/app_colors.dart';
import '../../../../../../shared/theme/app_text_styles.dart';

/// Displays the list of digital signers from the certificate endpoint.
class SignersCard extends StatelessWidget {
  final List<dynamic> signers;

  const SignersCard({super.key, required this.signers});

  @override
  Widget build(BuildContext context) {
    if (signers.isEmpty) return const SizedBox.shrink();

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      delay: const Duration(milliseconds: 120),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.forest.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    LucideIcons.badgeCheck,
                    color: AppColors.forest,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: TextDirection.rtl,
                    children: [
                      Text(
                        'سجل التواقيع الرقمية (الموقّعون)',
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontWeight: AppTextStyles.semiBold,
                          color: AppColors.charcoalDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'جميع الموظفين والمستخدمين الذين وقّعوا المعاملة رقمياً عبر الـ USB',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.charcoal.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.forest.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${signers.length} توقيع',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.forest,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Signers List
            ...signers.asMap().entries.map((entry) {
              final index = entry.key;
              final signer = entry.value as Map<String, dynamic>;

              final order = signer['signature_order']?.toString() ?? '${index + 1}';
              final firstName = signer['first_name']?.toString() ?? '';
              final fatherName = signer['father_name']?.toString() ?? '';
              final lastName = signer['last_name']?.toString() ?? '';
              final fullName = [firstName, fatherName, lastName]
                  .where((s) => s.isNotEmpty)
                  .join(' ');
              final motherName = signer['mother_name']?.toString();
              final nationalId = signer['national_id']?.toString() ?? '-';
              final stageName = signer['stage_name']?.toString() ??
                  signer['stage_code']?.toString() ??
                  'مرحلة المعاملة';
              final signedAt = signer['signed_at']?.toString() ?? '';

              return Container(
                margin: EdgeInsets.only(bottom: index < signers.length - 1 ? 12 : 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.goldLight.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.gold.withOpacity(0.2)),
                ),
                child: Row(
                  textDirection: TextDirection.rtl,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Signature Order Badge
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.forest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '#$order',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Signer Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        textDirection: TextDirection.rtl,
                        children: [
                          Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              Text(
                                fullName.isNotEmpty ? fullName : 'موقّع رقمي',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.charcoalDark,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.forest.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(LucideIcons.check,
                                        size: 12, color: AppColors.forest),
                                    const SizedBox(width: 4),
                                    Text(
                                      stageName,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.forest,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            textDirection: TextDirection.rtl,
                            spacing: 16,
                            runSpacing: 6,
                            children: [
                              _buildSignerMeta('الرقم الوطني', nationalId),
                              if (motherName != null &&
                                  motherName.trim().isNotEmpty)
                                _buildSignerMeta('اسم الأم', motherName),
                              if (signedAt.isNotEmpty)
                                _buildSignerMeta(
                                    'وقت التوقيع', _formatSignedAt(signedAt)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSignerMeta(String label, String value) {
    return Row(
      textDirection: TextDirection.rtl,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.charcoal.withOpacity(0.6),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoalDark,
          ),
        ),
      ],
    );
  }

  String _formatSignedAt(String rawDate) {
    try {
      final parsed = DateTime.tryParse(rawDate);
      if (parsed != null) {
        final local = parsed.toLocal();
        final year = local.year;
        final month = local.month.toString().padLeft(2, '0');
        final day = local.day.toString().padLeft(2, '0');
        final hour = local.hour.toString().padLeft(2, '0');
        final minute = local.minute.toString().padLeft(2, '0');
        return '$year-$month-$day $hour:$minute';
      }
    } catch (_) {}
    return rawDate;
  }
}
