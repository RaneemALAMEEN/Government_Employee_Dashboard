import '../../../../../../shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:government_employee_dashboard/features/internal_transactions/domain/entities/dynamic_widget_entity.dart';
import 'package:government_employee_dashboard/features/internal_transactions/presentation/widgets/dynamic_form_widget_renderer.dart';
import 'package:government_employee_dashboard/shared/theme/app_colors.dart';
import 'package:lucide_flutter/lucide_flutter.dart';


class TransactionFormWidget extends StatelessWidget {
  final List<DynamicWidgetEntity> widgets;
  final String formName;
  final Map<String, dynamic> formValues;
  final Set<String> formErrors;
  final Function(String, dynamic) onChanged;

  const TransactionFormWidget({
    Key? key,
    required this.widgets,
    required this.formName,
    required this.formValues,
    this.formErrors = const {},
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.forest, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.forest.withOpacity(0.12),
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
                right: BorderSide(color: AppColors.gold, width: 5),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Highlight Banner for Current Stage
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.forestLight.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.forest.withOpacity(0.25)),
                  ),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.forest,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(LucideIcons.penTool, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'المرحلة الحالية',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.charcoalDark,
                                      fontWeight: AppTextStyles.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'مطلوب التعبئة والعمل عليها',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.forest,
                                    fontWeight: AppTextStyles.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'يرجى مراجعة وتعبئة البيانات في الحقول أدناه الخاصة بمرحلتك للبدء بالتوقيع.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.charcoal.withOpacity(0.7),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    const Icon(LucideIcons.edit3, color: AppColors.forest, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        formName,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: AppTextStyles.bold,
                          color: AppColors.forest,
                        ),
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
                      hasError: formErrors.contains(id),
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
