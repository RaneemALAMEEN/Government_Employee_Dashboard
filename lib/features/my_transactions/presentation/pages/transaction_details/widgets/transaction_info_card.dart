import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../../../shared/theme/app_colors.dart';
import '../../../../../../shared/theme/app_text_styles.dart';

/// Displays key transaction metadata: ID, dates, priority, status.
class TransactionInfoCard extends StatelessWidget {
  final Map<String, dynamic> taskData;
  final String status;
  final String transactionNumber;

  const TransactionInfoCard({
    super.key,
    required this.taskData,
    required this.status,
    required this.transactionNumber,
  });

  @override
  Widget build(BuildContext context) {
    final submittedAt = taskData['submitted_at']?.toString() ?? '-';
    String? completedAt = taskData['completed_at']?.toString();
    final txId = taskData['transaction_id']?.toString() ?? '-';

    final history =
        taskData['transaction_history'] as Map<String, dynamic>? ?? {};
    final priorityVal = history['priority'] ?? taskData['process_priority'];

    // If completedAt is null but status is rejected, try to find it from the last rejected stage
    if ((completedAt == null || completedAt.isEmpty) && status == 'تم الرفض') {
      try {
        final historyData = history['data'] as Map<String, dynamic>? ?? {};
        final stages = historyData['stages'] as List? ?? [];
        final rejectedStage = stages.lastWhere(
          (stage) => stage['decision'] == 'reject',
          orElse: () => null,
        );
        if (rejectedStage != null) {
          completedAt = rejectedStage['completed_at']?.toString();
        }
      } catch (_) {}
    }

    String priorityLabel;
    Color priorityColor;
    IconData priorityIcon;

    if (priorityVal == 1) {
      priorityLabel = 'عالية';
      priorityColor = Colors.red.shade700;
      priorityIcon = LucideIcons.chevronsUp;
    } else if (priorityVal == 2) {
      priorityLabel = 'عادية';
      priorityColor = AppColors.forest;
      priorityIcon = LucideIcons.minus;
    } else {
      priorityLabel = 'منخفضة';
      priorityColor = Colors.blue.shade600;
      priorityIcon = LucideIcons.chevronDown;
    }

    // Determine status display
    Color statusColor;
    IconData statusIcon;
    String statusLabel;

    switch (status) {
      case 'منجزة':
        statusColor = AppColors.forest;
        statusIcon = LucideIcons.circleCheck;
        statusLabel = 'منجزة';
        break;
      case 'تم الرفض':
        statusColor = AppColors.error;
        statusIcon = LucideIcons.circleX;
        statusLabel = 'تم الرفض';
        break;
      case 'قيد التنفيذ':
        statusColor = Colors.orange.shade700;
        statusIcon = LucideIcons.loader;
        statusLabel = 'قيد التنفيذ';
        break;
      default:
        statusColor = Colors.blue.shade700;
        statusIcon = LucideIcons.clock;
        statusLabel = 'بانتظار الاستلام';
    }

    final infoItems = <_InfoItem>[
      _InfoItem(
        icon: LucideIcons.hash,
        label: 'رقم المعاملة',
        value: transactionNumber,
        color: AppColors.forest,
      ),
      _InfoItem(
        icon: LucideIcons.calendarPlus,
        label: 'تاريخ التقديم',
        value: submittedAt,
        color: Colors.blue.shade600,
      ),
      if (completedAt != null && completedAt.isNotEmpty && (status == 'منجزة' || status == 'تم الرفض')) ...[
        _InfoItem(
          icon: status == 'تم الرفض'
              ? LucideIcons.calendarX
              : LucideIcons.calendarCheck,
          label: status == 'تم الرفض' ? 'تاريخ الرفض' : 'تاريخ الإنجاز',
          value: completedAt,
          color: status == 'تم الرفض' ? AppColors.error : AppColors.forest,
        ),
      ],
      _InfoItem(
        icon: priorityIcon,
        label: 'الأولوية',
        value: priorityLabel,
        color: priorityColor,
      ),
      _InfoItem(
        icon: statusIcon,
        label: 'الحالة',
        value: statusLabel,
        color: statusColor,
      ),
    ];

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      delay: const Duration(milliseconds: 80),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.2)),
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
                    color: AppColors.forest.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(LucideIcons.clipboardList,
                      color: AppColors.forest, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'معلومات المعاملة',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: AppTextStyles.semiBold,
                    color: AppColors.charcoalDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Info Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 400;
                if (isNarrow) {
                  return Column(
                    children: infoItems
                        .map((item) => _buildInfoRow(item))
                        .toList(),
                  );
                }
                // Two-column layout
                final rows = <Widget>[];
                for (var i = 0; i < infoItems.length; i += 2) {
                  final left = infoItems[i];
                  final right =
                      i + 1 < infoItems.length ? infoItems[i + 1] : null;
                  rows.add(
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          Expanded(child: _buildInfoRow(left)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: right != null
                                ? _buildInfoRow(right)
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Column(children: rows);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(_InfoItem item) {
    return Row(
      textDirection: TextDirection.rtl,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(item.icon, size: 16, color: item.color),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.rtl,
            children: [
              Text(
                item.label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.charcoal.withValues(alpha: 0.55),
                  fontWeight: AppTextStyles.medium,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: AppTextStyles.semiBold,
                  color: AppColors.charcoalDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}
