import '../../domain/entities/internal_transaction_counts_entity.dart';

class InternalTransactionCountsModel extends InternalTransactionCountsEntity {
  const InternalTransactionCountsModel({
    required super.total,
    required super.inProgress,
    required super.completed,
  });

  factory InternalTransactionCountsModel.fromJson(Map<String, dynamic> json) {
    return InternalTransactionCountsModel(
      total: json['total'] ?? 0,
      inProgress: json['in_progress'] ?? 0,
      completed: json['completed'] ?? 0,
    );
  }
}