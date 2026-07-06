class StatisticsEmployeeEntity {
  final String id;
  final int? employeeId;
  final int? assignmentId;
  final String fullName;
  final String departmentName;
  final String roleName;
  final int pendingPickup;
  final int inProgress;
  final int activeTotal;
  final int completed;
  final int workloadPercent;
  final String status;
  final String statusLabel;

  const StatisticsEmployeeEntity({
    required this.id,
    required this.employeeId,
    required this.assignmentId,
    required this.fullName,
    required this.departmentName,
    required this.roleName,
    required this.pendingPickup,
    required this.inProgress,
    required this.activeTotal,
    required this.completed,
    required this.workloadPercent,
    required this.status,
    required this.statusLabel,
  });
}
