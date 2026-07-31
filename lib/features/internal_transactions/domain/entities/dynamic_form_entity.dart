import 'dynamic_widget_entity.dart';

class DynamicFormEntity {
  final int transactionId;
  final String formId;
  final String formName;
  final String note;
  final String decision;
  final int? expectedVersion;
  final bool requiresDigitalSignature;
  final List<DynamicWidgetEntity> widgets;
  final List<int> templateIds;
  final List<DynamicFormTemplateEntity> templates;
  final String? processName;
  final int? currentStageNumber;
  final int? totalStages;

  const DynamicFormEntity({
    required this.transactionId,
    required this.formId,
    required this.formName,
    required this.note,
    required this.decision,
    required this.requiresDigitalSignature,
    required this.widgets,
    this.expectedVersion,
    this.templateIds = const [],
    this.templates = const [],
    this.processName,
    this.currentStageNumber,
    this.totalStages,
  });
}

class DynamicFormTemplateEntity {
  final int id;
  final DynamicFormEntity config;

  const DynamicFormTemplateEntity({
    required this.id,
    required this.config,
  });
}
