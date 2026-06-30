import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../../../shared/theme/app_colors.dart';
import '../../../../../../shared/theme/app_text_styles.dart';

class EmployeeInfoCard extends StatelessWidget {
  final Map<String, dynamic>? applicant;

  const EmployeeInfoCard({super.key, required this.applicant});

  @override
  Widget build(BuildContext context) {
    if (applicant == null) return const SizedBox.shrink();

    final firstName = applicant!['first_name']?.toString() ?? '';
    final fatherName = applicant!['father_name']?.toString() ?? '';
    final lastName = applicant!['last_name']?.toString() ?? '';
    final fullName = '$firstName $fatherName $lastName'.trim();

    final nationalId = applicant!['national_id']?.toString() ?? '-';
    final phoneNumber = applicant!['phone_number']?.toString() ?? '-';

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      delay: const Duration(milliseconds: 50),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withOpacity(0.2)),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  Text(
                    fullName.isNotEmpty ? fullName : 'مقدم الطلب',
                    style: AppTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'مواطن مقدّم للطلب',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.goldDark),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    textDirection: TextDirection.rtl,
                    spacing: 24,
                    runSpacing: 8,
                    children: [
                      _buildInfoTag('الرقم الوطني', nationalId),
                      _buildInfoTag('رقم الهاتف', phoneNumber),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: AppColors.goldLight.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                LucideIcons.user,
                color: AppColors.forest,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTag(String label, String value) {
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
            fontWeight: FontWeight.w500,
            color: AppColors.charcoalDark,
          ),
        ),
      ],
    );
  }
}
