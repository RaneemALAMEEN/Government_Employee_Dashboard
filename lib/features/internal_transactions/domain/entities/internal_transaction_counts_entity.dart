class InternalTransactionCountsEntity {
  final int total;
  final int inProgress;
  final int completed;

  const InternalTransactionCountsEntity({
    required this.total,
    required this.inProgress,
    required this.completed,
  });
}