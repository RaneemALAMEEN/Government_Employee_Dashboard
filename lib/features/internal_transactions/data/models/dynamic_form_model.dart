import '../../domain/entities/dynamic_form_entity.dart';
import 'dynamic_widget_model.dart';

class DynamicFormModel extends DynamicFormEntity {
  const DynamicFormModel({
    required super.transactionId,
    required super.formId,
    required super.formName,
    required super.note,
    required super.decision,
    required super.requiresDigitalSignature,
    required super.widgets,
    super.expectedVersion,
    super.templateIds,
    super.templates,
  });

  factory DynamicFormModel.fromJson(Map<String, dynamic> json) {
    final config = json['config_json'] as Map<String, dynamic>? ?? json;
    final widgetsJson = config['widgets'] as List? ?? [];

    final templateJson =
        config['template'] as List? ?? config['templates'] as List? ?? [];
    final inlineTemplatesJson = templateJson
        .whereType<Map<String, dynamic>>()
        .where((item) => item['widgets'] is List)
        .toList();

    return DynamicFormModel(
      transactionId: json['transaction_id'] ?? 0,
      formId: config['form_id']?.toString() ?? '',
      formName: config['form_name']?.toString() ?? '',
      note: config['note']?.toString() ?? '',
      decision: config['decision']?.toString() ?? '',
      expectedVersion:
          int.tryParse(config['expected_version']?.toString() ?? ''),
      requiresDigitalSignature: config['requires_digital_signature'] == true,
      widgets: widgetsJson
          .map(
            (item) => DynamicWidgetModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      templateIds: templateJson
          .map((item) {
            if (item is Map<String, dynamic>) {
              return item['template_id'] ?? item['id'];
            }
            return item;
          })
          .where((id) => id != null)
          .map((id) => int.tryParse(id.toString()) ?? 0)
          .where((id) => id > 0)
          .toList(),
      templates: inlineTemplatesJson
          .map(
            (item) => DynamicFormTemplateEntity(
              id: int.tryParse(item['id']?.toString() ?? '') ?? 0,
              config: DynamicFormModel.fromJson(item),
            ),
          )
          .toList(),
    );
  }
}
