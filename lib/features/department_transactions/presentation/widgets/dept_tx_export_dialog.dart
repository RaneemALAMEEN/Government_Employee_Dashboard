import '../../../../core/constants/app_permissions.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/session_service.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../utils/dept_tx_export_service.dart';
import 'dept_tx_date_range_picker_dialog.dart';

class DeptTxExportDialog extends StatefulWidget {
  final String initialStatusFilter;
  final String? initialFromDate;
  final String? initialToDate;
  final int? departmentId;
  final String? departmentName;

  const DeptTxExportDialog({
    super.key,
    required this.initialStatusFilter,
    this.initialFromDate,
    this.initialToDate,
    this.departmentId,
    this.departmentName,
  });

  static Future<void> show({
    required BuildContext context,
    required String initialStatusFilter,
    String? initialFromDate,
    String? initialToDate,
    int? departmentId,
    String? departmentName,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DeptTxExportDialog(
        initialStatusFilter: initialStatusFilter,
        initialFromDate: initialFromDate,
        initialToDate: initialToDate,
        departmentId: departmentId,
        departmentName: departmentName,
      ),
    );
  }

  @override
  State<DeptTxExportDialog> createState() => _DeptTxExportDialogState();
}

class _DeptTxExportDialogState extends State<DeptTxExportDialog> {
  ExportFormat _selectedFormat = ExportFormat.excel;
  late String _selectedStatus;
  String? _fromDate;
  String? _toDate;
  bool _isExporting = false;
  String? _exportingStepText;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatusFilter;
    final session = getIt<SessionService>();
    final canViewCompleted =
        session.hasPermission(AppPermissions.getTaskCompletedByDepartment);
    final canViewRejected =
        session.hasPermission(AppPermissions.getTaskRejectedByDepartment);

    if (!canViewCompleted && !canViewRejected) {
      _selectedStatus = 'الكل';
    } else if (!canViewCompleted && _selectedStatus == 'منجزة') {
      _selectedStatus = 'مرفوضة';
    } else if (!canViewRejected && _selectedStatus == 'مرفوضة') {
      _selectedStatus = 'منجزة';
    } else if ((!canViewCompleted || !canViewRejected) &&
        _selectedStatus == 'الكل') {
      _selectedStatus = canViewCompleted ? 'منجزة' : 'مرفوضة';
    }
    _fromDate = widget.initialFromDate;
    _toDate = widget.initialToDate;
  }

  Future<void> _handleDatePick() async {
    await DeptTxDateRangePickerDialog.show(
      context: context,
      initialFromDate: _fromDate,
      initialToDate: _toDate,
      onApply: (from, to) {
        setState(() {
          _fromDate = from;
          _toDate = to;
        });
      },
    );
  }

  void _clearDateFilter() {
    setState(() {
      _fromDate = null;
      _toDate = null;
    });
  }

  Future<void> _startExport() async {
    setState(() {
      _isExporting = true;
      _exportingStepText = 'جارٍ جلب معاملات الدائرة...';
    });

    try {
      final transactions = await DeptTxExportService.fetchTransactions(
        statusFilter: _selectedStatus,
        fromDate: _fromDate,
        toDate: _toDate,
        departmentId: widget.departmentId,
      );

      if (!mounted) return;

      if (transactions.isEmpty) {
        setState(() => _isExporting = false);
        AppSnackBar.show(
          context,
          title: 'لا توجد بيانات',
          message: 'لم يتم العثور على أي معاملات تطابق الفلاتر المحددة للتصدير.',
          isError: true,
        );
        return;
      }

      setState(() {
        _exportingStepText = _selectedFormat == ExportFormat.excel
            ? 'جارٍ إنشاء وتنسيق ملف Excel...'
            : 'جارٍ توليد وتنسيق جدول PDF...';
      });

      final String filePath;
      if (_selectedFormat == ExportFormat.excel) {
        filePath = await DeptTxExportService.exportToExcel(
          transactions: transactions,
          statusFilter: _selectedStatus,
          fromDate: _fromDate,
          toDate: _toDate,
          departmentName: widget.departmentName,
        );
      } else {
        filePath = await DeptTxExportService.exportToPdf(
          transactions: transactions,
          statusFilter: _selectedStatus,
          fromDate: _fromDate,
          toDate: _toDate,
          departmentName: widget.departmentName,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop();

      final formatName = _selectedFormat == ExportFormat.excel ? 'Excel' : 'PDF';
      AppSnackBar.show(
        context,
        title: 'تم التصدير بنجاح',
        message: 'تم تصدير ملف $formatName (${transactions.length} معاملة) بنجاح وحفظه في مجلد التنزيلات:\n$filePath',
        isError: false,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isExporting = false);
        AppSnackBar.show(
          context,
          title: 'فشل التصدير',
          message: 'حدث خطأ أثناء تصدير البيانات: $e',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasDate = _fromDate != null || _toDate != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.forest.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        LucideIcons.fileSpreadsheet,
                        color: AppColors.forest,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'تصدير بيانات المعاملات',
                            style: AppTextStyles.headlineSmall,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.departmentName != null
                                ? 'تصدير معاملات ${widget.departmentName}'
                                : 'تصدير معاملات الدائرة حسب الفلاتر المطلوبة',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.charcoal.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!_isExporting)
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(LucideIcons.x, size: 20),
                        tooltip: 'إغلاق',
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Format Picker (Cards)
                const Text(
                  'صيغة الملف',
                  style: AppTextStyles.titleSmall,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildFormatCard(
                        format: ExportFormat.excel,
                        title: 'Excel (.xlsx)',
                        subtitle: 'جدول بيانات قابل للتعديل والفرز',
                        icon: LucideIcons.sheet,
                        accentColor: const Color(0xFF107C41),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFormatCard(
                        format: ExportFormat.pdf,
                        title: 'PDF (.pdf)',
                        subtitle: 'مستند رسمي منسق كجدول للطباعة',
                        icon: LucideIcons.fileText,
                        accentColor: const Color(0xFFD83B01),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Status Filter
                const Text(
                  'حالة المعاملات',
                  style: AppTextStyles.titleSmall,
                ),
                const SizedBox(height: 10),
                Builder(builder: (context) {
                  final session = getIt<SessionService>();
                  final canViewCompleted = session.hasPermission(
                      AppPermissions.getTaskCompletedByDepartment);
                  final canViewRejected = session.hasPermission(
                      AppPermissions.getTaskRejectedByDepartment);

                  final statusOptions = [
                    if (canViewCompleted && canViewRejected) 'الكل',
                    if (canViewCompleted) 'منجزة',
                    if (canViewRejected) 'مرفوضة',
                  ];

                  return Row(
                    children: [
                      for (int i = 0; i < statusOptions.length; i++) ...[
                        _buildStatusChip(statusOptions[i]),
                        if (i < statusOptions.length - 1)
                          const SizedBox(width: 10),
                      ],
                    ],
                  );
                }),
                const SizedBox(height: 20),

                // Date Range Filter
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'الفترة الزمنية',
                          style: AppTextStyles.titleSmall,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '(اختياري)',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.charcoal.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                    if (hasDate && !_isExporting)
                      TextButton.icon(
                        onPressed: _clearDateFilter,
                        icon: const Icon(LucideIcons.xCircle, size: 15, color: AppColors.umber),
                        label: Text(
                          'مسح الفترة',
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.umber),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: _isExporting ? null : _handleDatePick,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: hasDate ? AppColors.forest.withValues(alpha: 0.05) : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: hasDate ? AppColors.forest.withValues(alpha: 0.4) : AppColors.border,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.calendarRange,
                          size: 18,
                          color: hasDate ? AppColors.forest : AppColors.charcoal.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            hasDate
                                ? 'من: ${_fromDate ?? 'البداية'}   إلى: ${_toDate ?? 'الآن'}'
                                : 'تصدير كافة التواريخ (انقر لتحديد فترة)',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: hasDate ? AppColors.forest : AppColors.charcoal.withValues(alpha: 0.8),
                              fontWeight: hasDate ? AppTextStyles.semiBold : AppTextStyles.regular,
                            ),
                          ),
                        ),
                        Icon(
                          LucideIcons.chevronLeft,
                          size: 16,
                          color: AppColors.charcoal.withValues(alpha: 0.4),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Export Progress or Actions
                if (_isExporting)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.forest,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            _exportingStepText ?? 'جارٍ التصدير...',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.forest,
                              fontWeight: AppTextStyles.semiBold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          child: Text(
                            'إلغاء',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: AppTextStyles.semiBold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: _startExport,
                          icon: const Icon(LucideIcons.download, size: 18),
                          label: Text(
                            _selectedFormat == ExportFormat.excel
                                ? 'تصدير إلى Excel'
                                : 'تصدير كـ PDF',
                            style: AppTextStyles.titleSmall.copyWith(
                              color: Colors.white,
                              fontWeight: AppTextStyles.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.forest,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
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

  Widget _buildFormatCard({
    required ExportFormat format,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
  }) {
    final isSelected = _selectedFormat == format;

    return InkWell(
      onTap: _isExporting
          ? null
          : () => setState(() => _selectedFormat = format),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? accentColor : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: accentColor, size: 20),
                ),
                const Spacer(),
                Icon(
                  isSelected
                      ? LucideIcons.circleCheck
                      : LucideIcons.circle,
                  size: 18,
                  color: isSelected ? accentColor : AppColors.charcoal.withValues(alpha: 0.3),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                color: isSelected ? accentColor : AppColors.charcoalDark,
                fontWeight: AppTextStyles.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.charcoal.withValues(alpha: 0.7),
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final isSelected = _selectedStatus == status;

    return Expanded(
      child: InkWell(
        onTap: _isExporting
            ? null
            : () => setState(() => _selectedStatus = status),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.forest : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.forest : AppColors.border,
              width: 1.2,
            ),
          ),
          child: Text(
            status,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMedium.copyWith(
              color: isSelected ? Colors.white : AppColors.charcoal,
              fontWeight: isSelected ? AppTextStyles.bold : AppTextStyles.regular,
            ),
          ),
        ),
      ),
    );
  }
}
