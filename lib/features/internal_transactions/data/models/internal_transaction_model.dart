import '../../domain/entities/internal_transaction_entity.dart';

class InternalTransactionModel extends InternalTransactionEntity {
  const InternalTransactionModel({
    required super.transactionId,
    required super.idProcess,
    required super.processDefinitionName,
    required super.stageName,
    required super.progressPercent,
    required super.priority,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory InternalTransactionModel.fromJson(Map<String, dynamic> json) {
    return InternalTransactionModel(
      transactionId: json['transaction_id'] ?? 0,
      idProcess: json['id_process'] ?? '',
      processDefinitionName: json['process_definition_name'] ?? '',
      stageName: json['stage_name'] ?? '',
      progressPercent: json['progress_percent'] ?? 0,
      priority: json['priority'] ?? 0,
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}