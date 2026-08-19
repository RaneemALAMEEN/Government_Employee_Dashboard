import '../../../../../../shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:government_employee_dashboard/shared/theme/app_colors.dart';
import '../../../../domain/entities/my_transaction_entity.dart';
import 'transaction_action_buttons.dart';

class TransactionHeaderWidget extends StatelessWidget {
  final MyTransactionEntity txn;
  final bool isLocked;
  final bool lockedByMe;
  final bool submitting;
  final String? submittingMessage;
  final VoidCallback onPickup;
  final VoidCallback onRelease;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const TransactionHeaderWidget({
    Key? key,
    required this.txn,
    required this.isLocked,
    required this.lockedByMe,
    required this.submitting,
    this.submittingMessage,
    required this.onPickup,
    required this.onRelease,
    required this.onApprove,
    required this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color badgeBg;
    Color badgeFg;

    switch (txn.status) {
      case 'بانتظار الاستلام':
        badgeBg = Colors.blue.shade50;
        badgeFg = Colors.blue.shade700;
        break;
      case 'قيد التنفيذ':
        badgeBg = Colors.orange.shade50;
        badgeFg = Colors.orange.shade700;
        break;
      case 'منجزة':
        badgeBg = AppColors.forestLight.withOpacity(0.12);
        badgeFg = AppColors.forest;
        break;
      default: // تم الرفض
        badgeBg = AppColors.umber.withOpacity(0.08);
        badgeFg = AppColors.umber;
    }

    return FadeInDown(
      duration: const Duration(milliseconds: 300),
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          textDirection: TextDirection.rtl,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 12,
          children: [
            // Title + badges + reference
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  textDirection: TextDirection.rtl,
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      txn.type,
                      style: AppTextStyles.headlineLarge.copyWith(fontSize: 26, fontWeight: AppTextStyles.semiBold, color: AppColors.forest),
                    ),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        txn.status,
                        style: AppTextStyles.labelLarge.copyWith(fontWeight: AppTextStyles.medium, color: badgeFg),
                      ),
                    ),
                    if (txn.priority == 'عالية') ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.umber.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'مستعجل',
                          style: AppTextStyles.labelLarge.copyWith(fontWeight: AppTextStyles.medium, color: AppColors.umber),
                        ),
                      ),
                    ],
                    // Lock badge when locked by another employee
                    if (isLocked && !lockedByMe) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.red.shade200, width: 0.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.lock, size: 14, color: Colors.red.shade700),
                            const SizedBox(width: 4),
                            Text(
                              'مقفلة من موظف آخر',
                              style: AppTextStyles.labelLarge.copyWith(
                                fontWeight: AppTextStyles.medium,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  txn.number,
                  style: AppTextStyles.labelLarge.copyWith(fontWeight: AppTextStyles.medium, color: AppColors.charcoal.withOpacity(0.6)),
                ),
              ],
            ),

            // Actions Buttons
            TransactionActionButtons(
              status: txn.status,
              isLocked: isLocked,
              lockedByMe: lockedByMe,
              submitting: submitting,
              submittingMessage: submittingMessage,
              onPickup: onPickup,
              onRelease: onRelease,
              onApprove: onApprove,
              onReject: onReject,
            ),
          ],
        ),
      ),
    );
  }
}
