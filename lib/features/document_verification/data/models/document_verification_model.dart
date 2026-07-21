import '../../domain/entities/document_verification_entity.dart';

class ApplicantModel extends ApplicantEntity {
  const ApplicantModel({
    required super.firstName,
    required super.lastName,
    required super.fatherName,
    required super.motherName,
    required super.nationalId,
  });

  factory ApplicantModel.fromJson(Map<String, dynamic> json) => ApplicantModel(
        firstName: _text(json['first_name']),
        lastName: _text(json['last_name']),
        fatherName: _text(json['father_name']),
        motherName: _text(json['mother_name']),
        nationalId: _text(json['national_id']),
      );
}

class SignerModel extends SignerEntity {
  const SignerModel({
    required super.signatureOrder,
    required super.firstName,
    required super.lastName,
    required super.fatherName,
    required super.motherName,
    required super.nationalId,
  });

  factory SignerModel.fromJson(Map<String, dynamic> json) => SignerModel(
        signatureOrder: _integer(json['signature_order']),
        firstName: _text(json['first_name']),
        lastName: _text(json['last_name']),
        fatherName: _text(json['father_name']),
        motherName: _text(json['mother_name']),
        nationalId: _text(json['national_id']),
      );
}

class VerifiedTransactionModel extends VerifiedTransactionEntity {
  const VerifiedTransactionModel({
    required super.id,
    required super.status,
    required super.requestDate,
    required super.completedAt,
    required super.rejectedAt,
  });

  factory VerifiedTransactionModel.fromJson(Map<String, dynamic> json) =>
      VerifiedTransactionModel(
        id: _integer(json['id']),
        status: _text(json['status']),
        requestDate: _text(json['request_date']),
        completedAt: _text(json['completed_at']),
        rejectedAt: _text(json['rejected_at']),
      );
}

class TransactionHistoryModel extends TransactionHistoryEntity {
  const TransactionHistoryModel({
    required super.idProcess,
    required super.processName,
    required super.priority,
    required super.data,
  });

  factory TransactionHistoryModel.fromJson(Map<String, dynamic> json) =>
      TransactionHistoryModel(
        idProcess: _text(json['id_process']),
        processName: _text(json['process_name']),
        priority: _nullableInteger(json['priority']),
        data: TransactionHistoryDataModel.fromJson(_map(json['data'])),
      );
}

class TransactionHistoryApplicantModel
    extends TransactionHistoryApplicantEntity {
  const TransactionHistoryApplicantModel({
    required super.firstName,
    required super.lastName,
    required super.fatherName,
    required super.motherName,
    required super.nationalId,
  });

  factory TransactionHistoryApplicantModel.fromJson(
    Map<String, dynamic> json,
  ) =>
      TransactionHistoryApplicantModel(
        firstName: _text(json['first_name'] ?? json['first_name_employee']),
        lastName: _text(json['last_name'] ?? json['last_name_employee']),
        fatherName: _text(json['father_name'] ?? json['father_name_employee']),
        motherName: _text(json['mother_name'] ?? json['mother_name_employee']),
        nationalId: _text(json['national_id'] ?? json['national_id_employee']),
      );
}

class TransactionHistoryDataModel extends TransactionHistoryDataEntity {
  const TransactionHistoryDataModel({
    required super.applicant,
    required super.stages,
  });

  factory TransactionHistoryDataModel.fromJson(Map<String, dynamic> json) {
    final applicantMap = _map(json['applicant']);
    return TransactionHistoryDataModel(
      applicant: applicantMap.isEmpty
          ? null
          : TransactionHistoryApplicantModel.fromJson(applicantMap),
      stages: _listOfMaps(json['stages'])
          .map(TransactionHistoryStageModel.fromJson)
          .toList(growable: false),
    );
  }
}

class TransactionHistoryStageModel extends TransactionHistoryStageEntity {
  const TransactionHistoryStageModel({
    required super.stageName,
    required super.formName,
    required super.decision,
    required super.note,
    required super.rejectionReason,
    required super.completedBy,
    required super.completedAt,
    required super.widgets,
    required super.templates,
    required super.documentInstanceId,
    required super.generatedPdfUrl,
    required super.generatedDocument,
  });

  factory TransactionHistoryStageModel.fromJson(Map<String, dynamic> json) {
    final config = _map(json['config']);
    final widgetSource = json['widgets'] ?? config['widgets'];
    final templateSource = json['templates'] ??
        json['template'] ??
        config['templates'] ??
        config['template'];
    final generatedMap = _map(
      json['generated_document'] ?? json['generatedDocument'],
    );
    final generatedUrl = _firstText([
      json['generated_pdf_url'],
      json['generated_pdf_path'],
      generatedMap['url'],
      generatedMap['file_url'],
    ]);
    return TransactionHistoryStageModel(
      stageName: _firstText([
        json['stage_name'],
        json['name'],
        json['stage_type'],
        json['action'],
      ]),
      formName: _nullableText(json['form_name'] ?? config['form_name']),
      decision: _nullableText(json['decision']),
      note: _nullableText(json['note']),
      rejectionReason: _nullableText(
        json['rejection_reason'] ?? json['reject_reason'],
      ),
      completedBy: _nullableInteger(json['completed_by']),
      completedAt: _date(
        json['completed_at'] ?? json['generated_at'] ?? json['created_at'],
      ),
      widgets: _listOfMaps(widgetSource)
          .map(TransactionHistoryWidgetModel.fromJson)
          .toList(growable: false),
      templates: _templateMaps(templateSource)
          .map(TransactionHistoryTemplateModel.fromJson)
          .toList(growable: false),
      documentInstanceId: _nullableInteger(
        json['document_instance_id'] ?? json['id_document_instance'],
      ),
      generatedPdfUrl: generatedUrl.isEmpty ? null : generatedUrl,
      generatedDocument: generatedMap.isEmpty
          ? null
          : GeneratedDocumentModel.fromJson(generatedMap),
    );
  }
}

class TransactionHistoryWidgetModel extends TransactionHistoryWidgetEntity {
  const TransactionHistoryWidgetModel({
    required super.widgetType,
    required super.data,
    required super.value,
  });

  factory TransactionHistoryWidgetModel.fromJson(Map<String, dynamic> json) {
    final data = _map(json['data']);
    return TransactionHistoryWidgetModel(
      widgetType: _text(json['widget_type'] ?? json['type']),
      data: TransactionHistoryWidgetDataModel.fromJson(data),
      value: json.containsKey('value') ? json['value'] : data['value'],
    );
  }
}

class TransactionHistoryWidgetDataModel
    extends TransactionHistoryWidgetDataEntity {
  const TransactionHistoryWidgetDataModel({required super.label});

  factory TransactionHistoryWidgetDataModel.fromJson(
    Map<String, dynamic> json,
  ) =>
      TransactionHistoryWidgetDataModel(
        label: _firstText([json['label'], json['name'], json['title']]),
      );
}

class TransactionHistoryTemplateModel extends TransactionHistoryTemplateEntity {
  const TransactionHistoryTemplateModel({required super.values});

  factory TransactionHistoryTemplateModel.fromJson(
    Map<String, dynamic> json,
  ) =>
      TransactionHistoryTemplateModel(
        values: _map(json['value']).isNotEmpty ? _map(json['value']) : json,
      );
}

class GeneratedDocumentModel extends GeneratedDocumentEntity {
  const GeneratedDocumentModel({
    required super.url,
    required super.name,
    required super.generatedAt,
  });

  factory GeneratedDocumentModel.fromJson(Map<String, dynamic> json) =>
      GeneratedDocumentModel(
        url: _firstText([json['url'], json['file_url'], json['path']]),
        name: _firstText([json['name'], json['original_name']]),
        generatedAt: _date(json['generated_at'] ?? json['created_at']),
      );
}

class FinalDocumentModel extends FinalDocumentEntity {
  const FinalDocumentModel({
    required super.available,
    required super.fileUrl,
  });

  factory FinalDocumentModel.fromJson(Map<String, dynamic> json) =>
      FinalDocumentModel(
        available: _boolean(json['available']),
        fileUrl: _text(json['file_url']),
      );
}

class DocumentVerificationModel extends DocumentVerificationEntity {
  const DocumentVerificationModel({
    required super.applicant,
    required super.signers,
    required super.transaction,
    required super.transactionHistory,
    required super.finalDocument,
  });

  factory DocumentVerificationModel.fromJson(Map<String, dynamic> json) {
    final data = _map(json['data']);
    final transactionMap = _map(data['transaction']);
    final historyMap = _map(data['transaction_history']);
    if (_text(historyMap['id_process']).isEmpty &&
        _text(transactionMap['id_process']).isNotEmpty) {
      historyMap['id_process'] = transactionMap['id_process'];
    }
    if (_text(historyMap['process_name']).isEmpty &&
        _text(transactionMap['process_name']).isNotEmpty) {
      historyMap['process_name'] = transactionMap['process_name'];
    }
    final history = TransactionHistoryModel.fromJson(historyMap);
    final primaryApplicant = ApplicantModel.fromJson(_map(data['applicant']));
    final historyApplicant = history.data.applicant;
    final applicant = ApplicantModel(
      firstName: primaryApplicant.firstName.isNotEmpty
          ? primaryApplicant.firstName
          : historyApplicant?.firstName ?? '',
      lastName: primaryApplicant.lastName.isNotEmpty
          ? primaryApplicant.lastName
          : historyApplicant?.lastName ?? '',
      fatherName: primaryApplicant.fatherName.isNotEmpty
          ? primaryApplicant.fatherName
          : historyApplicant?.fatherName ?? '',
      motherName: primaryApplicant.motherName.isNotEmpty
          ? primaryApplicant.motherName
          : historyApplicant?.motherName ?? '',
      nationalId: primaryApplicant.nationalId.isNotEmpty
          ? primaryApplicant.nationalId
          : historyApplicant?.nationalId ?? '',
    );
    final rawSigners =
        data['signers'] is List ? data['signers'] as List : const [];
    final signers = rawSigners
        .whereType<Map>()
        .map((value) => SignerModel.fromJson(Map<String, dynamic>.from(value)))
        .toList(growable: false)
      ..sort((a, b) => a.signatureOrder.compareTo(b.signatureOrder));
    return DocumentVerificationModel(
      applicant: applicant,
      signers: signers,
      transaction: VerifiedTransactionModel.fromJson(transactionMap),
      transactionHistory: history,
      finalDocument: FinalDocumentModel.fromJson(_map(data['final_document'])),
    );
  }
}

Map<String, dynamic> _map(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
String _text(dynamic value) => value?.toString().trim() ?? '';
int _integer(dynamic value) =>
    value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;
bool _boolean(dynamic value) =>
    value == true || value == 1 || value?.toString().toLowerCase() == 'true';

int? _nullableInteger(dynamic value) {
  if (value == null) return null;
  return value is int ? value : int.tryParse(value.toString());
}

String? _nullableText(dynamic value) {
  final result = _text(value);
  return result.isEmpty ? null : result;
}

String _firstText(List<dynamic> values) {
  for (final value in values) {
    final result = _text(value);
    if (result.isNotEmpty) return result;
  }
  return '';
}

DateTime? _date(dynamic value) {
  if (value == null) return null;
  final raw = value.toString().trim();
  final parsed = DateTime.tryParse(raw);
  if (parsed != null) return parsed;
  final parts = raw.split('/');
  if (parts.length != 3) return null;
  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  return day == null || month == null || year == null
      ? null
      : DateTime(year, month, day);
}

List<Map<String, dynamic>> _listOfMaps(dynamic value) => value is List
    ? value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false)
    : const [];

List<Map<String, dynamic>> _templateMaps(dynamic value) {
  if (value is Map) return [Map<String, dynamic>.from(value)];
  return _listOfMaps(value);
}
