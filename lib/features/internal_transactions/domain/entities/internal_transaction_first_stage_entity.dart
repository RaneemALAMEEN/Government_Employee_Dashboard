class InternalTransactionFirstStageEntity {
  final int transactionId;
  final String stageCode;
  final String stageName;
  final String authType;
  final int? completedBy;
  final FirstStageContentEntity content;

  const InternalTransactionFirstStageEntity({
    required this.transactionId,
    required this.stageCode,
    required this.stageName,
    required this.authType,
    required this.completedBy,
    required this.content,
  });
}

class FirstStageContentEntity {
  final String stageName;
  final String formId;
  final String formName;
  final String decision;
  final String note;
  final String rejectionReason;
  final int? completedBy;
  final String completedAt;
  final List<FirstStageWidgetEntity> widgets;
  final List<FirstStageTemplateEntity> templates;

  const FirstStageContentEntity({
    required this.stageName,
    required this.formId,
    required this.formName,
    required this.decision,
    required this.note,
    required this.rejectionReason,
    required this.completedBy,
    required this.completedAt,
    required this.widgets,
    required this.templates,
  });
}

class FirstStageWidgetEntity {
  final String widgetType;
  final Map<String, dynamic> data;
  final dynamic value;

  const FirstStageWidgetEntity({
    required this.widgetType,
    required this.data,
    required this.value,
  });

  String get id => data['id']?.toString() ?? '';
  String get label => data['label']?.toString() ?? 'حقل';
}

class FirstStageTemplateEntity {
  final int? templateId;
  final int? documentInstanceId;
  final String generatedPdfPath;
  final Map<String, dynamic> value;

  const FirstStageTemplateEntity({
    required this.templateId,
    required this.documentInstanceId,
    required this.generatedPdfPath,
    required this.value,
  });
}
