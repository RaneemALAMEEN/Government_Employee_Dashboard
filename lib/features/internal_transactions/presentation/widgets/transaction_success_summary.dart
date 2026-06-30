import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';

class TransactionSuccessSummary extends StatelessWidget {
  final Map<String, dynamic> submittedTransaction;
  final VoidCallback onBack;

  const TransactionSuccessSummary({
    super.key,
    required this.submittedTransaction,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final transactionData =
        submittedTransaction['data'] as Map<String, dynamic>? ?? {};

    final widgets = transactionData['widgets'] as List? ?? [];

    final formName = transactionData['form_name']?.toString() ?? '-';
    final stageName = transactionData['stage_name']?.toString() ?? '-';
    final completedAt = transactionData['completed_at']?.toString() ?? '-';
    final workflowStatus = _workflowStatusText(
      submittedTransaction['workflow_status']?.toString(),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 36),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gold.withOpacity(0.25)),
            boxShadow: [
              BoxShadow(
                color: AppColors.charcoal.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 72,
              ),
              const SizedBox(height: 16),
              const Text(
                'تم توقيع وتقديم المعاملة بنجاح',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.forest,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'تم حفظ البيانات وإرسال المعاملة للمرحلة التالية.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.goldDark,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 28),
              _sectionTitle('ملخص المعاملة'),
              const SizedBox(height: 12),
              _summaryRow('اسم المعاملة', formName),
              if (stageName != '-' && stageName != formName)
                _summaryRow('المرحلة الحالية', stageName),
              _summaryRow('تاريخ التقديم', completedAt),
              _summaryRow('حالة سير العمل', workflowStatus),
              const SizedBox(height: 24),
              _sectionTitle('البيانات المقدّمة'),
              const SizedBox(height: 12),
              if (widgets.isEmpty)
                const Text(
                  'لا توجد بيانات إضافية.',
                  style: TextStyle(color: AppColors.charcoal),
                )
              else
                ...widgets.map(_buildWidgetValueRow),
              const SizedBox(height: 26),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('العودة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forest,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildWidgetValueRow(dynamic item) {
    final widget = item as Map<String, dynamic>;
    final data = widget['data'] as Map<String, dynamic>? ?? {};
    final label = data['label']?.toString() ?? '-';
    final value = _formatValue(widget['value']);

    return _summaryRow(label, value);
  }

  static Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.forest,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  static Widget _summaryRow(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.goldLight.withOpacity(0.25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.charcoalDark,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.charcoal,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _workflowStatusText(String? status) {
    switch (status) {
      case 'running':
        return 'قيد المعالجة';
      case 'completed':
        return 'مكتملة';
      case 'rejected':
        return 'مرفوضة';
      default:
        return status ?? '-';
    }
  }

  static String _formatValue(dynamic value) {
    if (value == null) return '-';

    if (value is List) {
      if (value.isEmpty) return '-';

      return value.map((item) {
        if (item is Map) {
          return item['original_name']?.toString() ??
              item['path']?.toString() ??
              item.toString();
        }

        return item.toString();
      }).join('، ');
    }

    if (value is Map) {
      return value['value']?.toString() ??
          value['name']?.toString() ??
          value.toString();
    }

    return value.toString();
  }
}
