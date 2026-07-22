abstract class DepartmentCertificateEvent {}

class LoadDepartmentCertificate extends DepartmentCertificateEvent {
  final String transactionId;

  LoadDepartmentCertificate(this.transactionId);
}
