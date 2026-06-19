import '../../domain/entities/dynamic_form_entity.dart';
import 'dynamic_widget_model.dart';

class DynamicFormModel extends DynamicFormEntity {
  const DynamicFormModel({
    required super.transactionId,
    required super.formId,
    required super.formName,
    required super.requiresDigitalSignature,
    required super.widgets,
  });

  factory DynamicFormModel.fromJson(Map<String, dynamic> json) {
    final config = json['config_json'] as Map<String, dynamic>? ?? json;
    final widgetsJson = config['widgets'] as List? ?? [];

    return DynamicFormModel(
      transactionId: json['transaction_id'] ?? 0,
      formId: config['form_id']?.toString() ?? '',
      formName: config['form_name']?.toString() ?? '',
      requiresDigitalSignature:
          config['requires_digital_signature'] == true,
      widgets: widgetsJson
          .map(
            (item) => DynamicWidgetModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}