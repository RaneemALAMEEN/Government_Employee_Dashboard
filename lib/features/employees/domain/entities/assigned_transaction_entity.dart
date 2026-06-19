class AssignedTransactionEntity {
  final String number;
  final String type;
  final String receiveDate;
  final String priority;
  final String status;
  final int durationDays;

  const AssignedTransactionEntity({
    required this.number,
    required this.type,
    required this.receiveDate,
    required this.priority,
    required this.status,
    required this.durationDays,
  });
}
