import '../../domain/entities/organization_employee_entity.dart';

class OrganizationEmployeeModel extends OrganizationEmployeeEntity {
  const OrganizationEmployeeModel({
    required super.assignmentId,
    required super.organizationDepartmentRolesId,
    required super.priority,
    required super.isActive,
    required super.userId,
    required super.userName,
    required super.email,
    required super.phoneNumber,
    required super.firstName,
    required super.lastName,
    required super.fatherName,
    required super.motherName,
    required super.nationalId,
    required super.userIsActive,
  });

  factory OrganizationEmployeeModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? const {};
    return OrganizationEmployeeModel(
      assignmentId: _asInt(json['assignment_id']),
      organizationDepartmentRolesId:
          _asInt(json['organization_department_roles_id']),
      priority: _asInt(json['priority']),
      isActive: _asBool(json['is_active']),
      userId: _asInt(user['id']),
      userName: user['userName']?.toString() ?? '',
      email: user['email']?.toString() ?? '',
      phoneNumber: user['phone_number']?.toString() ?? '',
      firstName: user['first_name']?.toString() ?? '',
      lastName: user['last_name']?.toString() ?? '',
      fatherName: user['father_name']?.toString() ?? '',
      motherName: user['mother_name']?.toString() ?? '',
      nationalId: user['national_id']?.toString() ?? '',
      userIsActive: _asBool(user['is_active']),
    );
  }

  static int _asInt(dynamic value) =>
      value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;

  static bool _asBool(dynamic value) =>
      value == true || value == 1 || value?.toString().toLowerCase() == 'true';
}
