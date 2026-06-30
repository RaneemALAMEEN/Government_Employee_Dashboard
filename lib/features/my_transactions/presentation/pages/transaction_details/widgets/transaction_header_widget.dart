import '../../../../../../shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:government_employee_dashboard/shared/theme/app_colors.dart';
import '../../../../domain/entities/my_transaction_entity.dart';
import 'transaction_action_buttons.dart';

class TransactionHeaderWidget extends StatelessWidget {
  final MyTransactionEntity txn;
  final bool isLocked;
  final bool lockedByMe;
  final bool submitting;
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
