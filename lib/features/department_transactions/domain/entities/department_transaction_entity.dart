class DepartmentTransactionEntity {
  final int transactionId;
  final String transactionNumber;
  final String type;
  final String typeCode;
  final String applicantName;
  final String department;
  final String date;
  final int progressPercent;
  final String status;
  final String statusLabel;
  final String taskId;
  final String taskName;
  final String processName;
  final int processPriority;

  const DepartmentTransactionEntity({
    required this.transactionId,
    required this.transactionNumber,
    required this.type,
    required this.typeCode,
    required this.applicantName,
    required this.department,
    required this.date,
    required this.progressPercent,
    required this.status,
    required this.statusLabel,
    required this.taskId,
    required this.taskName,
    required this.processName,
    required this.processPriority,
  });

  DepartmentTransactionEntity copyWith({
    int? transactionId,
    String? transactionNumber,
    String? type,
    String? typeCode,
    String? applicantName,
    String? department,
    String? date,
    int? progressPercent,
    String? status,
    String? statusLabel,
    String? taskId,
    String? taskName,
    String? processName,
    int? processPriority,
  }) {
    return DepartmentTransactionEntity(
      transactionId: transactionId ?? this.transactionId,
      transactionNumber: transactionNumber ?? this.transactionNumber,
      type: type ?? this.type,
      typeCode: typeCode ?? this.typeCode,
      applicantName: applicantName ?? this.applicantName,
      department: department ?? this.department,
      date: date ?? this.date,
      progressPercent: progressPercent ?? this.progressPercent,
      status: status ?? this.status,
      statusLabel: statusLabel ?? this.statusLabel,
      taskId: taskId ?? this.taskId,
      taskName: taskName ?? this.taskName,
      processName: processName ?? this.processName,
      processPriority: processPriority ?? this.processPriority,
    );
  }
}
