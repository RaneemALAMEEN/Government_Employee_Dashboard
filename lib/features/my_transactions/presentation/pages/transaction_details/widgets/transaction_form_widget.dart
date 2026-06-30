import '../../../../../../shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:government_employee_dashboard/features/internal_transactions/domain/entities/dynamic_widget_entity.dart';
import 'package:government_employee_dashboard/features/internal_transactions/presentation/widgets/dynamic_form_widget_renderer.dart';
import 'package:government_employee_dashboard/shared/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TransactionFormWidget extends StatelessWidget {
  final List<DynamicWidgetEntity> widgets;
  final String formName;
  final Map<String, dynamic> formValues;
  final Function(String, dynamic) onChanged;

  const TransactionFormWidget({
    Key? key,
    required this.widgets,
    required this.formName,
    required this.formValues,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filteredWidgets = widgets.where((w) {
      final wData = w.data;
      return wData['is_gateway'] != true && wData['id'] != 'decision';
    }).toList();

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.forest.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              textDirection: TextDirection.rtl,
              children: [
                const Icon(LucideIcons.edit3, color: AppColors.forest, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    formName,
                    style: AppTextStyles.titleMedium.copyWith(fontWeight: AppTextStyles.bold, color: AppColors.forest),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...filteredWidgets.map((widgetConfig) {
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
