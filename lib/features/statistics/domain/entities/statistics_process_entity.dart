class StatisticsProcessEntity {
  final int processDefinitionId;
  final String processName;
  final String processCode;
  final String transactionTypeName;
  final String transactionTypeCode;
  final bool isActive;
  final String approvalStatus;
  final int pendingPickup;
  final int inProgress;
  final int completed;
  final int rejected;
  final List<String> departments;

  const StatisticsProcessEntity({
    required this.processDefinitionId,
    required this.processName,
    required this.processCode,
    required this.transactionTypeName,
    required this.transactionTypeCode,
    required this.isActive,
    required this.approvalStatus,
    required this.pendingPickup,
    required this.inProgress,
    required this.completed,
    required this.rejected,
    required this.departments,
  });
}
