import '../../../../document_verification/domain/entities/document_verification_entity.dart';

abstract class DepartmentCertificateState {}

class DepartmentCertificateInitial extends DepartmentCertificateState {}

class DepartmentCertificateLoading extends DepartmentCertificateState {}

class DepartmentCertificateLoaded extends DepartmentCertificateState {
  final DocumentVerificationEntity data;

  DepartmentCertificateLoaded({required this.data});
}

class DepartmentCertificateFailure extends DepartmentCertificateState {
  final String message;

  DepartmentCertificateFailure(this.message);
}

