abstract class DepartmentCertificateState {}

class DepartmentCertificateInitial extends DepartmentCertificateState {}

class DepartmentCertificateLoading extends DepartmentCertificateState {}

class DepartmentCertificateLoaded extends DepartmentCertificateState {
  final Map<String, dynamic> data;

  DepartmentCertificateLoaded({required this.data});
}

class DepartmentCertificateFailure extends DepartmentCertificateState {
  final String message;

  DepartmentCertificateFailure(this.message);
}
