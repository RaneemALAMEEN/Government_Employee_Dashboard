import '../../domain/entities/user_role.dart';

class UserRoleModel extends UserRole {
  UserRoleModel({
    required super.organizationDepartmentRolesId,
    super.organizationId,
    required super.roleId,
    required super.roleName,
    required super.departmentId,
    required super.departmentName,
  });

  factory UserRoleModel.fromJson(Map<String, dynamic> json) {
    return UserRoleModel(
      organizationDepartmentRolesId:
          json['organization_department_roles_id'] ?? 0,
      organizationId: _asInt(
        json['organization_id'] ?? json['organizationId'],
      ),
      roleId: json['role_id'] ?? 0,
      roleName: json['role_name'] ?? '',
      departmentId: json['department_id'] ?? 0,
      departmentName: json['department_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'organization_department_roles_id': organizationDepartmentRolesId,
      'organization_id': organizationId,
      'role_id': roleId,
      'role_name': roleName,
      'department_id': departmentId,
      'department_name': departmentName,
    };
  }

  static int _asInt(dynamic value) =>
      value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;
}
