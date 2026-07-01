import '../../../../../../shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:government_employee_dashboard/shared/theme/app_colors.dart';
import 'package:lucide_flutter/lucide_flutter.dart';


class TransactionActionButtons extends StatelessWidget {
  final String status;
  final bool isLocked;
  final bool lockedByMe;
  final bool submitting;
  final VoidCallback onPickup;
  final VoidCallback onRelease;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const TransactionActionButtons({
    Key? key,
    required this.status,
    required this.isLocked,
    required this.lockedByMe,
    required this.submitting,
    required this.onPickup,
    required this.onRelease,
    required this.onApprove,
    required this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (status == 'منجزة' || status == 'تم الرفض') {
      return const SizedBox.shrink();
    }

    if (!isLocked) {
      return ElevatedButton(
        onPressed: submitting ? null : onPickup,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.forest,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: submitting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Text(
                'استلام المعاملة',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: AppTextStyles.semiBold,
                  color: Colors.white,
                ),
              ),
      );
    } else if (lockedByMe) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // E-signature approval button
          ElevatedButton.icon(
            onPressed: submitting ? null : onApprove,
            icon: submitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(LucideIcons.shieldCheck, size: 16),
            label: const Text('موافقة وتوقيع إلكتروني'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E5649),
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
          const SizedBox(width: 8),

          // Reject button
          ElevatedButton.icon(
            onPressed: submitting ? null : onReject,
            icon: const Icon(LucideIcons.xCircle, size: 16),
            label: const Text('رفض'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B1D2A),
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
          const SizedBox(width: 8),

          // Cancel pickup button
          OutlinedButton(
            onPressed: submitting ? null : onRelease,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.charcoal,
              side: BorderSide(color: AppColors.gold.withOpacity(0.4)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('إلغاء استلام المعاملة'),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
