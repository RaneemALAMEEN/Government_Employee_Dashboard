import '../../domain/entities/statistics_process_entity.dart';

class StatisticsProcessModel extends StatisticsProcessEntity {
  const StatisticsProcessModel({
    required super.processDefinitionId,
    required super.processName,
    required super.processCode,
    required super.transactionTypeName,
    required super.transactionTypeCode,
    required super.isActive,
    required super.approvalStatus,
    required super.pendingPickup,
    required super.inProgress,
    required super.completed,
    required super.rejected,
    required super.departments,
  });

  factory StatisticsProcessModel.fromJson(Map<String, dynamic> json) {
    final transactions = json['transactions'] as Map<String, dynamic>? ?? {};
    final departments = json['departments'] as List? ?? [];

    return StatisticsProcessModel(
      processDefinitionId: _asInt(json['process_definition_id']) ?? 0,
      processName: json['process_name']?.toString() ?? '',
      processCode: json['process_code']?.toString() ?? '',
      transactionTypeName: json['transaction_type_name']?.toString() ?? '',
      transactionTypeCode: json['transaction_type_code']?.toString() ?? '',
      isActive: json['is_active'] == true,
      approvalStatus: json['approval_status']?.toString() ?? '',
      pendingPickup: _asInt(transactions['pending_pickup']) ?? 0,
      inProgress: _asInt(transactions['in_progress']) ?? 0,
      completed: _asInt(transactions['completed']) ?? 0,
      rejected: _asInt(transactions['rejected']) ?? 0,
      departments: departments
          .whereType<Map>()
          .map((item) => item['name']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .toList(),
    );
  }
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}
