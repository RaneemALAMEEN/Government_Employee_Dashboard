import 'package:equatable/equatable.dart';

class PersonIdentityEntity extends Equatable {
  final String firstName;
  final String lastName;
  final String fatherName;
  final String motherName;
  final String nationalId;

  const PersonIdentityEntity({
    required this.firstName,
    required this.lastName,
    required this.fatherName,
    required this.motherName,
    required this.nationalId,
  });

  String get fullName =>
      [firstName, lastName].where((value) => value.trim().isNotEmpty).join(' ');

  @override
  List<Object?> get props =>
      [firstName, lastName, fatherName, motherName, nationalId];
}

class ApplicantEntity extends PersonIdentityEntity {
  const ApplicantEntity({
    required super.firstName,
    required super.lastName,
    required super.fatherName,
    required super.motherName,
    required super.nationalId,
  });
}

class SignerEntity extends PersonIdentityEntity {
  final int signatureOrder;

  const SignerEntity({
    required this.signatureOrder,
    required super.firstName,
    required super.lastName,
    required super.fatherName,
    required super.motherName,
    required super.nationalId,
  });

  @override
  List<Object?> get props => [...super.props, signatureOrder];
}

class VerifiedTransactionEntity extends Equatable {
  final int id;
  final String status;
  final String requestDate;
  final String completedAt;
  final String rejectedAt;

  const VerifiedTransactionEntity({
    required this.id,
    required this.status,
    required this.requestDate,
    required this.completedAt,
    required this.rejectedAt,
  });

  @override
  List<Object?> get props => [id, status, requestDate, completedAt, rejectedAt];
}

class TransactionHistoryEntity extends Equatable {
  final String idProcess;
  final String processName;
  final int? priority;
  final TransactionHistoryDataEntity data;

  const TransactionHistoryEntity({
    required this.idProcess,
    required this.processName,
    required this.priority,
    required this.data,
  });

  @override
  List<Object?> get props => [idProcess, processName, priority, data];
}

class TransactionHistoryApplicantEntity extends PersonIdentityEntity {
  const TransactionHistoryApplicantEntity({
    required super.firstName,
    required super.lastName,
    required super.fatherName,
    required super.motherName,
    required super.nationalId,
  });
}

class TransactionHistoryDataEntity extends Equatable {
  final TransactionHistoryApplicantEntity? applicant;
  final List<TransactionHistoryStageEntity> stages;

  const TransactionHistoryDataEntity({
    required this.applicant,
    required this.stages,
  });

  @override
  List<Object?> get props => [applicant, stages];
}

class TransactionHistoryStageEntity extends Equatable {
  final String stageName;
  final String? formName;
  final String? decision;
  final String? note;
  final String? rejectionReason;
  final int? completedBy;
  final DateTime? completedAt;
  final List<TransactionHistoryWidgetEntity> widgets;
  final List<TransactionHistoryTemplateEntity> templates;
  final int? documentInstanceId;
  final String? generatedPdfUrl;
  final GeneratedDocumentEntity? generatedDocument;

  const TransactionHistoryStageEntity({
    required this.stageName,
    required this.formName,
    required this.decision,
    required this.note,
    required this.rejectionReason,
    required this.completedBy,
    required this.completedAt,
    required this.widgets,
    required this.templates,
    required this.documentInstanceId,
    required this.generatedPdfUrl,
    required this.generatedDocument,
  });

  String get displayName {
    final preferred = (stageName.isNotEmpty ? stageName : formName) ?? '';
    if (_looksLikeGeneratePdf(preferred) ||
        generatedPdfUrl?.isNotEmpty == true) {
      return 'توليد الوثيقة';
    }
    return preferred.isEmpty ? 'مرحلة المعاملة' : preferred;
  }

  bool get isDocumentGeneration =>
      _looksLikeGeneratePdf(stageName) ||
      _looksLikeGeneratePdf(formName ?? '') ||
      generatedPdfUrl?.isNotEmpty == true ||
      generatedDocument?.url.isNotEmpty == true;

  @override
  List<Object?> get props => [
        stageName,
        formName,
        decision,
        note,
        rejectionReason,
        completedBy,
        completedAt,
        widgets,
        templates,
        documentInstanceId,
        generatedPdfUrl,
        generatedDocument,
      ];
}

class TransactionHistoryWidgetEntity extends Equatable {
  final String widgetType;
  final TransactionHistoryWidgetDataEntity data;
  final dynamic value;

  const TransactionHistoryWidgetEntity({
    required this.widgetType,
    required this.data,
    required this.value,
  });

  @override
  List<Object?> get props => [widgetType, data, value];
}

class TransactionHistoryWidgetDataEntity extends Equatable {
  final String label;

  const TransactionHistoryWidgetDataEntity({required this.label});

  @override
  List<Object?> get props => [label];
}

class TransactionHistoryTemplateEntity extends Equatable {
  final Map<String, dynamic> values;

  const TransactionHistoryTemplateEntity({required this.values});

  @override
  List<Object?> get props => [values];
}

class GeneratedDocumentEntity extends Equatable {
  final String url;
  final String name;
  final DateTime? generatedAt;

  const GeneratedDocumentEntity({
    required this.url,
    required this.name,
    required this.generatedAt,
  });

  @override
  List<Object?> get props => [url, name, generatedAt];
}

bool _looksLikeGeneratePdf(String value) {
  final normalized =
      value.toUpperCase().replaceAll('-', '_').replaceAll(' ', '_');
  return normalized.contains('GENERATE_PDF') ||
      normalized.contains('PDF_GENERATION');
}

class FinalDocumentEntity extends Equatable {
  final bool available;
  final String fileUrl;

  const FinalDocumentEntity({
    required this.available,
    required this.fileUrl,
  });

  @override
  List<Object?> get props => [available, fileUrl];
}

class DocumentVerificationEntity extends Equatable {
  final ApplicantEntity applicant;
  final List<SignerEntity> signers;
  final VerifiedTransactionEntity transaction;
  final TransactionHistoryEntity transactionHistory;
  final FinalDocumentEntity finalDocument;

  const DocumentVerificationEntity({
    required this.applicant,
    required this.signers,
    required this.transaction,
    required this.transactionHistory,
    required this.finalDocument,
  });

  @override
  List<Object?> get props => [
        applicant,
        signers,
        transaction,
        transactionHistory,
        finalDocument,
      ];
}
