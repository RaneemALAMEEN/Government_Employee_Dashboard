class MyTransactionEntity {
  final String number;
  final String type;
  final String applicant;
  final String department;
  final String date;
  final String priority; // 'عالية', 'عادية', 'منخفضة'
  final String status;   // 'بانتظار توقيعي', 'منجزة', 'تم الرفض'
  final bool canSign;

  const MyTransactionEntity({
    required this.number,
    required this.type,
    required this.applicant,
    required this.department,
    required this.date,
    required this.priority,
    required this.status,
    required this.canSign,
  });

  MyTransactionEntity copyWith({
    String? number,
    String? type,
    String? applicant,
    String? department,
    String? date,
    String? priority,
    String? status,
    bool? canSign,
  }) {
    return MyTransactionEntity(
      number: number ?? this.number,
      type: type ?? this.type,
      applicant: applicant ?? this.applicant,
      department: department ?? this.department,
      date: date ?? this.date,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      canSign: canSign ?? this.canSign,
    );
  }
}
