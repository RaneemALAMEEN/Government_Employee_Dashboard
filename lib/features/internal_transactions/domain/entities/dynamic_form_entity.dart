import 'dynamic_widget_entity.dart';

class DynamicFormEntity {
  final int transactionId;
  final String formId;
  final String formName;
  final bool requiresDigitalSignature;
  final List<DynamicWidgetEntity> widgets;
  final List<int> templateIds;

  const DynamicFormEntity({
    required this.transactionId,
    required this.formId,
    required this.formName,
    required this.requiresDigitalSignature,
    required this.widgets,
    this.templateIds = const [],
  });
}