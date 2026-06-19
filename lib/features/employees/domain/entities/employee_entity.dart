import 'assigned_transaction_entity.dart';

class EmployeeEntity {
  final String id;
  final String name;
  final String department;
  final String role;
  final String status; // 'نشط', 'غير نشط', 'مثقل'
  final int activeTxCount;
  final int doneTxCount;
  final int workloadPercentage;
  final String avatarLetter;
  
  // Detailed properties
  final String email;
  final String phone;
  final String directManager;
  final String hireDate;
  final String lastLogin;
  final String joinDate;
  final String serviceDuration;
  final int receivedTxCount;
  final int lateTxCount;
  final int completionRate;
  final double avgProcessingTimeDays;
  final List<int> monthlyTxHistory;
  final List<String> permissions;
  final List<AssignedTransactionEntity> assignedTransactions;

  const EmployeeEntity({
    required this.id,
    required this.name,
    required this.department,
    required this.role,
    required this.status,
    required this.activeTxCount,
    required this.doneTxCount,
    required this.workloadPercentage,
    required this.avatarLetter,
    required this.email,
    required this.phone,
    required this.directManager,
    required this.hireDate,
    required this.lastLogin,
    required this.joinDate,
    required this.serviceDuration,
    required this.receivedTxCount,
    required this.lateTxCount,
    required this.completionRate,
    required this.avgProcessingTimeDays,
    required this.monthlyTxHistory,
    required this.permissions,
    required this.assignedTransactions,
  });
}
