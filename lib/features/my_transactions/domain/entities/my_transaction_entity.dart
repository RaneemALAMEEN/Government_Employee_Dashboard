class MyTransactionEntity {
  final String idTask;
  final String number;
  final String type;
  final String applicant;
  final String department;
  final String date;
  final String priority; // 'عالية', 'عادية', 'منخفضة'
  final String status;   // 'بانتظار الاستلام', 'قيد التنفيذ', 'منجزة', 'تم الرفض'
  final bool canSign;
  final String? decision; // 'approve', 'reject' etc.
  final String? completedAt;
  final String processName; // اسم المعاملة (process_name)
  final int progressPercent; // نسبة الإنجاز (progress_percent)
  final int? transactionId; // معرف المعاملة الرقمي (transaction_id)
  final bool isLockedByMe; // هل تم استلامها/قفلها من قبلي (is_locked_by_me)

  const MyTransactionEntity({
    required this.idTask,
    required this.number,
    required this.type,
    required this.applicant,
    required this.department,
    required this.date,
    required this.priority,
    required this.status,
    required this.canSign,
    this.decision,
    this.completedAt,
    this.processName = '',
    this.progressPercent = 0,
    this.transactionId,
    this.isLockedByMe = false,
  });

  MyTransactionEntity copyWith({
    String? idTask,
    String? number,
    String? type,
    String? applicant,
    String? department,
    String? date,
    String? priority,
    String? status,
    bool? canSign,
    String? decision,
    String? completedAt,
    String? processName,
    int? progressPercent,
    int? transactionId,
    bool? isLockedByMe,
  }) {
    return MyTransactionEntity(
      idTask: idTask ?? this.idTask,
      number: number ?? this.number,
      type: type ?? this.type,
      applicant: applicant ?? this.applicant,
      department: department ?? this.department,
      date: date ?? this.date,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      canSign: canSign ?? this.canSign,
      decision: decision ?? this.decision,
      completedAt: completedAt ?? this.completedAt,
      processName: processName ?? this.processName,
      progressPercent: progressPercent ?? this.progressPercent,
      transactionId: transactionId ?? this.transactionId,
      isLockedByMe: isLockedByMe ?? this.isLockedByMe,
    );
  }
}
