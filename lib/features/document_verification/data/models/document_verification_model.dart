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
  const TransactionHistoryModel({required super.idProcess});

  factory TransactionHistoryModel.fromJson(Map<String, dynamic> json) =>
      TransactionHistoryModel(idProcess: _text(json['id_process']));
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
    final rawSigners =
        data['signers'] is List ? data['signers'] as List : const [];
    final signers = rawSigners
        .whereType<Map>()
        .map((value) => SignerModel.fromJson(Map<String, dynamic>.from(value)))
        .toList(growable: false)
      ..sort((a, b) => a.signatureOrder.compareTo(b.signatureOrder));
    return DocumentVerificationModel(
      applicant: ApplicantModel.fromJson(_map(data['applicant'])),
      signers: signers,
      transaction: VerifiedTransactionModel.fromJson(_map(data['transaction'])),
      transactionHistory:
          TransactionHistoryModel.fromJson(_map(data['transaction_history'])),
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
