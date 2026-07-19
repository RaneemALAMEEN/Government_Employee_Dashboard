import '../../domain/entities/department_role_entity.dart';

class DepartmentRoleModel extends DepartmentRoleEntity {
  const DepartmentRoleModel({
    required super.id,
    required super.organizationDepartmentRolesId,
    required super.name,
    required super.code,
  });

  factory DepartmentRoleModel.fromJson(Map<String, dynamic> json) {
    return DepartmentRoleModel(
      id: _asInt(json['id']),
      organizationDepartmentRolesId:
          _asInt(json['organization_department_roles_id']),
      name: json['name']?.toString().trim() ?? '',
      code: json['code']?.toString().trim() ?? '',
    );
  }

  static int _asInt(dynamic value) =>
      value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;
}
