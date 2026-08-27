import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../domain/entities/org_node_entity.dart';
import '../utils/org_hierarchy_export_service.dart';

enum OrgExportFormat { excel, pdf }

class OrgHierarchyExportDialog extends StatefulWidget {
  final List<OrgNodeEntity> nodes;
  final String? organizationName;

  const OrgHierarchyExportDialog({
    super.key,
    required this.nodes,
    this.organizationName,
  });

  static Future<void> show({
    required BuildContext context,
    required List<OrgNodeEntity> nodes,
    String? organizationName,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => OrgHierarchyExportDialog(
        nodes: nodes,
        organizationName: organizationName,
      ),
    );
  }

  @override
  State<OrgHierarchyExportDialog> createState() =>
      _OrgHierarchyExportDialogState();
}

class _OrgHierarchyExportDialogState extends State<OrgHierarchyExportDialog> {
  OrgExportFormat _selectedFormat = OrgExportFormat.excel;
  bool _isExporting = false;
  String? _exportingStepText;

  Future<void> _startExport() async {
    if (widget.nodes.isEmpty) {
      AppSnackBar.show(
        context,
        title: 'لا توجد بيانات',
        message: 'لا توجد بيانات متاحة في الهيكل التنظيمي لتصديرها.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isExporting = true;
      _exportingStepText = _selectedFormat == OrgExportFormat.excel
          ? 'جارٍ تجهيز وتنسيق جدول Excel...'
          : 'جارٍ توليد وتنسيق مستند PDF...';
    });

    try {
      final String filePath;
      if (_selectedFormat == OrgExportFormat.excel) {
        filePath = await OrgHierarchyExportService.exportToExcel(
          nodes: widget.nodes,
          organizationName: widget.organizationName,
        );
      } else {
        filePath = await OrgHierarchyExportService.exportToPdf(
          nodes: widget.nodes,
          organizationName: widget.organizationName,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop();

      final formatName =
          _selectedFormat == OrgExportFormat.excel ? 'Excel' : 'PDF';
      AppSnackBar.show(
        context,
        title: 'تم التصدير بنجاح',
        message:
            'تم تصدير ملف الهيكل التنظيمي بصيغة $formatName بنجاح وحفظه في مجلد التنزيلات:\n$filePath',
        isError: false,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isExporting = false);
        AppSnackBar.show(
          context,
          title: 'فشل التصدير',
          message: 'حدث خطأ أثناء تصدير بيانات الهيكل التنظيمي: $e',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
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
                        LucideIcons.network,
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
                            'تصدير الهيكل التنظيمي',
                            style: AppTextStyles.headlineSmall,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'تصدير كامل بيانات الوحدات التنظيمية والمسميات الوظيفية',
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

                // Info Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.forest.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.forest.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        LucideIcons.info,
                        size: 18,
                        color: AppColors.forest,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'سيتم تصدير كامل بيانات الهيكل التنظيمي (الدوائر، الأقسام، الشُعب، المسميات الوظيفية، وبيانات الموظفين) بشكل شامل ومباشر.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.forestDark,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Format Picker (Cards)
                const Text(
                  'اختر صيغة الملف',
                  style: AppTextStyles.titleSmall,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildFormatCard(
                        format: OrgExportFormat.excel,
                        title: 'Excel (.xlsx)',
                        subtitle: 'جدول بيانات متكامل لفرز وتحليل الهيكل',
                        icon: LucideIcons.sheet,
                        accentColor: const Color(0xFF107C41),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFormatCard(
                        format: OrgExportFormat.pdf,
                        title: 'PDF (.pdf)',
                        subtitle: 'مستند رسمي منسق كجدول للطباعة والمشاركة',
                        icon: LucideIcons.fileText,
                        accentColor: const Color(0xFFD83B01),
                      ),
                    ),
                  ],
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
                            _selectedFormat == OrgExportFormat.excel
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
    required OrgExportFormat format,
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
          color:
              isSelected ? accentColor.withValues(alpha: 0.05) : Colors.white,
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
                  isSelected ? LucideIcons.circleCheck : LucideIcons.circle,
                  size: 18,
                  color: isSelected
                      ? accentColor
                      : AppColors.charcoal.withValues(alpha: 0.3),
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
}
