import '../../domain/entities/my_transaction_entity.dart';

class MyTransactionModel extends MyTransactionEntity {
  const MyTransactionModel({
    required super.idTask,
    required super.number,
    required super.type,
    required super.applicant,
    required super.department,
    required super.date,
    required super.priority,
    required super.status,
    required super.canSign,
  });

  factory MyTransactionModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'] as String? ?? '';
    
    // Map status:
    // "pending_pickup" -> "بانتظار الاستلام"
    // "in_progress" -> "قيد التنفيذ"
    // "completed" -> "منجزة"
    // "rejected" -> "تم الرفض"
    String statusLabel = 'بانتظار الاستلام';
    if (rawStatus == 'in_progress') {
      statusLabel = 'قيد التنفيذ';
    } else if (rawStatus == 'completed') {
      statusLabel = 'منجزة';
    } else if (rawStatus == 'rejected') {
      statusLabel = 'تم الرفض';
    }

    // Map priority:
    // 1 -> "عالية", 2 -> "عادية", others -> "منخفضة"
    final rawPriority = json['process_priority'];
    String priorityLabel = 'منخفضة';
    if (rawPriority == 1) {
      priorityLabel = 'عالية';
    } else if (rawPriority == 2) {
      priorityLabel = 'عادية';
    }

    // canSign is true if status is pending_pickup or in_progress
    final canSign = rawStatus == 'pending_pickup' || rawStatus == 'in_progress';
    final idTask = json['task_id']?.toString() ?? json['id_task']?.toString() ?? json['transaction_number']?.toString() ?? '';

    return MyTransactionModel(
      idTask: idTask,
      number: json['transaction_number'] as String? ?? '',
      type: json['type'] as String? ?? '',
      applicant: json['applicant_name'] as String? ?? '',
      department: json['department'] as String? ?? '',
      date: json['date'] as String? ?? '',
      priority: priorityLabel,
      status: statusLabel,
      canSign: canSign,
    );
  }
}
