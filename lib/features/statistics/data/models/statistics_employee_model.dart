import '../../domain/entities/statistics_employee_entity.dart';

class StatisticsEmployeeModel extends StatisticsEmployeeEntity {
  const StatisticsEmployeeModel({
    required super.id,
    required super.employeeId,
    required super.assignmentId,
    required super.fullName,
    required super.departmentName,
    required super.roleName,
    required super.pendingPickup,
    required super.inProgress,
    required super.activeTotal,
    required super.completed,
    required super.workloadPercent,
    required super.status,
    required super.statusLabel,
  });

  factory StatisticsEmployeeModel.fromJson(Map<String, dynamic> json) {
    final employeeId = _asInt(json['employee_id']);
    final firstName = json['first_name']?.toString() ?? '';
    final lastName = json['last_name']?.toString() ?? '';
    final department = json['department'] as Map<String, dynamic>? ?? {};
    final role = json['role'] as Map<String, dynamic>? ?? {};
    final tasks = json['tasks'] as Map<String, dynamic>? ?? {};

    return StatisticsEmployeeModel(
      id: employeeId?.toString() ?? json['assignment_id']?.toString() ?? '',
      employeeId: employeeId,
      assignmentId: _asInt(json['assignment_id']),
      fullName: '$firstName $lastName'.trim(),
      departmentName: department['name']?.toString() ?? '',
      roleName: role['name']?.toString() ?? '',
      pendingPickup: _asInt(tasks['pending_pickup']) ?? 0,
      inProgress: _asInt(tasks['in_progress']) ?? 0,
      activeTotal: _asInt(tasks['active_total']) ?? 0,
      completed: _asInt(tasks['completed']) ?? 0,
      workloadPercent: _asInt(json['workload_percent']) ?? 0,
      status: json['status']?.toString() ?? '',
      statusLabel: json['status_label']?.toString() ?? '',
    );
  }
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}
