import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

class DeptTxDateRangePickerDialog extends StatefulWidget {
  final String? initialFromDate;
  final String? initialToDate;
  final Function(String? fromDate, String? toDate) onApply;

  const DeptTxDateRangePickerDialog({
    super.key,
    this.initialFromDate,
    this.initialToDate,
    required this.onApply,
  });

  static Future<void> show({
    required BuildContext context,
    String? initialFromDate,
    String? initialToDate,
    required Function(String? fromDate, String? toDate) onApply,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => DeptTxDateRangePickerDialog(
        initialFromDate: initialFromDate,
        initialToDate: initialToDate,
        onApply: onApply,
      ),
    );
  }

  @override
  State<DeptTxDateRangePickerDialog> createState() =>
      _DeptTxDateRangePickerDialogState();
}

class _DeptTxDateRangePickerDialogState
    extends State<DeptTxDateRangePickerDialog> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    if (widget.initialFromDate != null) {
      _startDate = DateTime.tryParse(widget.initialFromDate!);
    }
    if (widget.initialToDate != null) {
      _endDate = DateTime.tryParse(widget.initialToDate!);
    }
  }

  Widget _buildDatePickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(
          primary: AppColors.forest,
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: AppColors.charcoalDark,
        ),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? (_endDate ?? now),
      firstDate: DateTime(2020),
      lastDate: _endDate ?? DateTime(2100),
      helpText: 'اختر تاريخ البداية (من)',
      cancelText: 'إلغاء',
      confirmText: 'تحديد',
      builder: _buildDatePickerTheme,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? (_startDate ?? now),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'اختر تاريخ النهاية (إلى)',
      cancelText: 'إلغاء',
      confirmText: 'تحديد',
      builder: _buildDatePickerTheme,
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'غير محدد';
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  void _setPreset(String type) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (type) {
      case 'today':
        setState(() {
          _startDate = today;
          _endDate = today;
        });
        break;
      case 'last7':
        setState(() {
          _startDate = today.subtract(const Duration(days: 7));
          _endDate = today;
        });
        break;
      case 'last30':
        setState(() {
          _startDate = today.subtract(const Duration(days: 30));
          _endDate = today;
        });
        break;
      case 'thisMonth':
        setState(() {
          _startDate = DateTime(today.year, today.month, 1);
          _endDate = today;
        });
        break;
      case 'lastMonth':
        final firstDayOfCurrentMonth = DateTime(today.year, today.month, 1);
        final lastDayOfPrevMonth =
            firstDayOfCurrentMonth.subtract(const Duration(days: 1));
        setState(() {
          _startDate =
              DateTime(lastDayOfPrevMonth.year, lastDayOfPrevMonth.month, 1);
          _endDate = lastDayOfPrevMonth;
        });
        break;
    }
  }

  void _apply() {
    if (_startDate != null && _endDate != null) {
      widget.onApply(_formatDate(_startDate), _formatDate(_endDate));
    } else if (_startDate != null) {
      widget.onApply(_formatDate(_startDate), _formatDate(_startDate));
    } else {
      widget.onApply(null, null);
    }
    Navigator.of(context).pop();
  }

  void _clear() {
    widget.onApply(null, null);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 10,
        backgroundColor: Colors.white,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.forest.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        LucideIcons.calendarRange,
                        color: AppColors.forest,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تحديد الفترة الزمنية',
                            style: AppTextStyles.headlineSmall.copyWith(
                              fontWeight: AppTextStyles.bold,
                              color: AppColors.charcoalDark,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'اختر تاريخ البداية وتاريخ النهاية لتصفية المعاملات',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.charcoal.withValues(alpha: 0.65),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 20),
                      color: AppColors.charcoal.withValues(alpha: 0.7),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'إغلاق',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 20),

                // Date Picker Pickers (Side-by-side or stacked on small screens)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 420;
                    if (isNarrow) {
                      return Column(
                        children: [
                          _DatePickerCard(
                            label: 'تاريخ البداية (من)',
                            formattedDate: _formatDate(_startDate),
                            hasValue: _startDate != null,
                            onTap: _pickStartDate,
                          ),
                          const SizedBox(height: 12),
                          _DatePickerCard(
                            label: 'تاريخ النهاية (إلى)',
                            formattedDate: _formatDate(_endDate),
                            hasValue: _endDate != null,
                            onTap: _pickEndDate,
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(
                          child: _DatePickerCard(
                            label: 'تاريخ البداية (من)',
                            formattedDate: _formatDate(_startDate),
                            hasValue: _startDate != null,
                            onTap: _pickStartDate,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _DatePickerCard(
                            label: 'تاريخ النهاية (إلى)',
                            formattedDate: _formatDate(_endDate),
                            hasValue: _endDate != null,
                            onTap: _pickEndDate,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Quick presets
                Text(
                  'اختصارات سريعة:',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoal.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _PresetChip(
                      label: 'اليوم',
                      onTap: () => _setPreset('today'),
                    ),
                    _PresetChip(
                      label: 'آخر 7 أيام',
                      onTap: () => _setPreset('last7'),
                    ),
                    _PresetChip(
                      label: 'آخر 30 يوماً',
                      onTap: () => _setPreset('last30'),
                    ),
                    _PresetChip(
                      label: 'هذا الشهر',
                      onTap: () => _setPreset('thisMonth'),
                    ),
                    _PresetChip(
                      label: 'الشهر الماضي',
                      onTap: () => _setPreset('lastMonth'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Divider(height: 1),
                const SizedBox(height: 18),

                // Actions Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_startDate != null || _endDate != null)
                      TextButton.icon(
                        onPressed: _clear,
                        icon: const Icon(
                          LucideIcons.rotateCcw,
                          size: 16,
                          color: AppColors.error,
                        ),
                        label: const Text(
                          'إلغاء الفلترة',
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            side: BorderSide(
                              color: AppColors.gold.withValues(alpha: 0.4),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'إلغاء',
                            style: TextStyle(
                              color: AppColors.charcoalDark,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: _apply,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.forest,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 11,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(LucideIcons.check, size: 16),
                          label: const Text(
                            'تطبيق الفلترة',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DatePickerCard extends StatelessWidget {
  final String label;
  final String formattedDate;
  final bool hasValue;
  final VoidCallback onTap;

  const _DatePickerCard({
    required this.label,
    required this.formattedDate,
    required this.hasValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: hasValue
            ? AppColors.forestLight.withValues(alpha: 0.12)
            : AppColors.goldLight.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasValue
              ? AppColors.forest.withValues(alpha: 0.6)
              : AppColors.gold.withValues(alpha: 0.35),
          width: hasValue ? 1.4 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          hoverColor: AppColors.forest.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: hasValue
                        ? AppColors.forestDark
                        : AppColors.charcoal.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          LucideIcons.calendar,
                          size: 16,
                          color: hasValue
                              ? AppColors.forest
                              : AppColors.charcoal.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                hasValue ? FontWeight.w700 : FontWeight.w500,
                            color: hasValue
                                ? AppColors.charcoalDark
                                : AppColors.charcoal.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: hasValue
                            ? AppColors.forest
                            : AppColors.forest.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'اختيار',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: hasValue ? Colors.white : AppColors.forest,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.4),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: AppColors.charcoalDark,
            ),
          ),
        ),
      ),
    );
  }
}
