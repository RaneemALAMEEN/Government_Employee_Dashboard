import '../../domain/entities/internal_transaction_first_stage_entity.dart';

class InternalTransactionFirstStageModel
    extends InternalTransactionFirstStageEntity {
  const InternalTransactionFirstStageModel({
    required super.transactionId,
    required super.stageCode,
    required super.stageName,
    required super.authType,
    required super.completedBy,
    required super.content,
  });

  factory InternalTransactionFirstStageModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    return InternalTransactionFirstStageModel(
      transactionId: _asInt(data['transaction_id']) ?? 0,
      stageCode: data['stage_code']?.toString() ?? '',
      stageName: data['stage_name']?.toString() ?? '',
      authType: data['auth_type']?.toString() ?? '',
      completedBy: _asInt(data['completed_by']),
      content: FirstStageContentModel.fromJson(
        data['content'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class FirstStageContentModel extends FirstStageContentEntity {
  const FirstStageContentModel({
    required super.stageName,
    required super.formId,
    required super.formName,
    required super.decision,
    required super.note,
    required super.rejectionReason,
    required super.completedBy,
    required super.completedAt,
    required super.widgets,
    required super.templates,
  });

  factory FirstStageContentModel.fromJson(Map<String, dynamic> json) {
    final widgets = json['widgets'] as List? ?? [];
    final templates = json['templates'] as List? ?? [];

    return FirstStageContentModel(
      stageName: json['stage_name']?.toString() ?? '',
      formId: json['form_id']?.toString() ?? '',
      formName: json['form_name']?.toString() ?? '',
      decision: json['decision']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
      rejectionReason: json['rejection_reason']?.toString() ?? '',
      completedBy: _asInt(json['completed_by']),
      completedAt: json['completed_at']?.toString() ?? '',
      widgets: widgets
          .whereType<Map>()
          .map(
            (item) => FirstStageWidgetModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      templates: templates
          .whereType<Map>()
          .map(
            (item) => FirstStageTemplateModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
    );
  }
}

class FirstStageWidgetModel extends FirstStageWidgetEntity {
  const FirstStageWidgetModel({
    required super.widgetType,
    required super.data,
    required super.value,
  });

  factory FirstStageWidgetModel.fromJson(Map<String, dynamic> json) {
    return FirstStageWidgetModel(
      widgetType: json['widget_type']?.toString() ?? '',
      data: Map<String, dynamic>.from(json['data'] as Map? ?? {}),
      value: json['value'],
    );
  }
}

class FirstStageTemplateModel extends FirstStageTemplateEntity {
  const FirstStageTemplateModel({
    required super.templateId,
    required super.documentInstanceId,
    required super.generatedPdfPath,
    required super.value,
  });

  factory FirstStageTemplateModel.fromJson(Map<String, dynamic> json) {
    return FirstStageTemplateModel(
      templateId: _asInt(json['id_template']),
      documentInstanceId: _asInt(json['id_document_instance']),
      generatedPdfPath: json['generated_pdf_path']?.toString() ?? '',
      value: Map<String, dynamic>.from(json['value'] as Map? ?? {}),
    );
  }
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}
