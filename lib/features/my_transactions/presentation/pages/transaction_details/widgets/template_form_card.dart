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
  final String? templateFilePath;
  final VoidCallback? onDownload;
  final Function(String, dynamic) onChanged;

  const TemplateFormCard({
    super.key,
    required this.templateName,
    required this.widgets,
    required this.formValues,
    required this.onChanged,
    this.templateFilePath,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    if (widgets.isEmpty && templateFilePath == null) return const SizedBox.shrink();

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              textDirection: TextDirection.rtl,
              children: [
                const Icon(LucideIcons.fileSignature, color: AppColors.goldDark, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'قالب: $templateName',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: AppTextStyles.bold,
                      color: AppColors.goldDark,
                    ),
                  ),
                ),
                if (templateFilePath != null && templateFilePath!.isNotEmpty)
                  IconButton(
                    icon: const Icon(LucideIcons.download, color: AppColors.forest),
                    tooltip: 'تحميل ملف القالب',
                    onPressed: onDownload,
                  ),
              ],
            ),
            const SizedBox(height: 20),
            ...widgets.map((widgetConfig) {
              final id = widgetConfig.data['id']?.toString() ?? '';
              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: DynamicFormWidgetRenderer(
                  widgetEntity: widgetConfig,
                  value: formValues[id],
                  onChanged: (value) => onChanged(id, value),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
