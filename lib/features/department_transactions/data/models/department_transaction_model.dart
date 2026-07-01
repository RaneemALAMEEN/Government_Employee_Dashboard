import '../../domain/entities/department_transaction_entity.dart';

class DepartmentTransactionModel extends DepartmentTransactionEntity {
  const DepartmentTransactionModel({
    required super.transactionId,
    required super.transactionNumber,
    required super.type,
    required super.typeCode,
    required super.applicantName,
    required super.department,
    required super.date,
    required super.progressPercent,
    required super.status,
    required super.statusLabel,
    required super.taskId,
    required super.taskName,
    required super.processName,
    required super.processPriority,
  });

  factory DepartmentTransactionModel.fromJson(Map<String, dynamic> json) {
    return DepartmentTransactionModel(
      transactionId: json['transaction_id'] as int? ?? 0,
      transactionNumber: json['transaction_number'] as String? ?? '',
      type: json['type'] as String? ?? '',
      typeCode: json['type_code'] as String? ?? '',
      applicantName: json['applicant_name'] as String? ?? '',
      department: json['department'] as String? ?? '',
      date: json['date'] as String? ?? '',
      progressPercent: json['progress_percent'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      statusLabel: json['status_label'] as String? ?? '',
      taskId: json['task_id'] as String? ?? '',
      taskName: json['task_name'] as String? ?? '',
      processName: json['process_name'] as String? ?? '',
      processPriority: json['process_priority'] as int? ?? 0,
    );
  }
}
