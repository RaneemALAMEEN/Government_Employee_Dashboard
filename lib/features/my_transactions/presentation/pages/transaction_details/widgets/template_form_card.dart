import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:government_employee_dashboard/features/internal_transactions/domain/entities/dynamic_widget_entity.dart';
import 'package:government_employee_dashboard/features/internal_transactions/presentation/widgets/dynamic_form_widget_renderer.dart';
import 'package:government_employee_dashboard/shared/theme/app_colors.dart';
import 'package:government_employee_dashboard/shared/theme/app_text_styles.dart';

class TemplateFormCard extends StatelessWidget {
  final String templateName;
  final List<DynamicWidgetEntity> widgets;
  final Map<String, dynamic> formValues;
  final Set<String> formErrors;
  final String? templateFilePath;
  final VoidCallback? onDownload;
  final VoidCallback? onView;
  final bool isReadOnly;
  final Function(String, dynamic) onChanged;

  const TemplateFormCard({
    super.key,
    required this.templateName,
    required this.widgets,
    required this.formValues,
    this.formErrors = const {},
    required this.onChanged,
    this.templateFilePath,
    this.onDownload,
    this.onView,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    if (widgets.isEmpty && templateFilePath == null) return const SizedBox.shrink();

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.goldDark, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: AppColors.forest, width: 5),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.goldLight.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                  ),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      const Icon(LucideIcons.fileSignature, color: AppColors.goldDark, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'قالب المرحلة الحالية',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.goldDark,
                          fontWeight: AppTextStyles.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Expanded(
                      child: Text(
                        'قالب: $templateName',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: AppTextStyles.bold,
                          color: AppColors.goldDark,
                        ),
                      ),
                    ),
                    if (templateFilePath != null && templateFilePath!.isNotEmpty) ...[
                      IconButton(
                        icon: const Icon(LucideIcons.eye, color: AppColors.forest),
                        tooltip: 'عرض القالب',
                        onPressed: onView,
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.download, color: AppColors.goldDark),
                        tooltip: 'تحميل ملف القالب',
                        onPressed: onDownload,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
                ...widgets.map((widgetConfig) {
                  final id = widgetConfig.data['id']?.toString() ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: AbsorbPointer(
                      absorbing: isReadOnly,
                      child: DynamicFormWidgetRenderer(
                        widgetEntity: widgetConfig,
                        value: formValues[id],
                        onChanged: (value) => onChanged(id, value),
                        hasError: formErrors.contains(id),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
