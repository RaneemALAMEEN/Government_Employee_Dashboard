class InternalTransactionEntity {
  final int transactionId;
  final String idProcess;
  final String processDefinitionName;
  final String stageName;
  final int progressPercent;
  final int priority;
  final String status;
  final String createdAt;
  final String updatedAt;

  const InternalTransactionEntity({
    required this.transactionId,
    required this.idProcess,
    required this.processDefinitionName,
    required this.stageName,
    required this.progressPercent,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
}