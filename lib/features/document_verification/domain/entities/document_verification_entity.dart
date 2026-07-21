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

  const TransactionHistoryEntity({required this.idProcess});

  @override
  List<Object?> get props => [idProcess];
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
