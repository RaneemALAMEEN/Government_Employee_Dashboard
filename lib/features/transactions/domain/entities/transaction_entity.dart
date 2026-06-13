class TransactionEntity {
  final String id;
  final String type;
  final String applicant;
  final String department;
  final String date;
  final String priority;
  final String status;
  final bool needsSignature;
  final bool isUrgent;

  const TransactionEntity({
    required this.id,
    required this.type,
    required this.applicant,
    required this.department,
    required this.date,
    required this.priority,
    required this.status,
    required this.needsSignature,
    required this.isUrgent,
  });
}