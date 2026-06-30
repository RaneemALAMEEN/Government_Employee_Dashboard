class DepartmentTransactionEntity {
  final String number;
  final String type;
  final String classification;
  final String date;
  final String assignedTo;
  final bool isAssignedToMe;
  final String status; // 'قيد الانتظار', 'قيد المعالجة', 'منجزة', 'مرفوضة'

  const DepartmentTransactionEntity({
    required this.number,
    required this.type,
    required this.classification,
    required this.date,
    required this.assignedTo,
    required this.isAssignedToMe,
    required this.status,
  });

  DepartmentTransactionEntity copyWith({
    String? number,
    String? type,
    String? classification,
    String? date,
    String? assignedTo,
    bool? isAssignedToMe,
    String? status,
  }) {
    return DepartmentTransactionEntity(
      number: number ?? this.number,
      type: type ?? this.type,
      classification: classification ?? this.classification,
      date: date ?? this.date,
      assignedTo: assignedTo ?? this.assignedTo,
      isAssignedToMe: isAssignedToMe ?? this.isAssignedToMe,
      status: status ?? this.status,
    );
  }
}
