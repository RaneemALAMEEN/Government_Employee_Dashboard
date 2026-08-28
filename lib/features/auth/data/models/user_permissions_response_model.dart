class UserPermissionsResponseModel {
  final int userId;
  final String userName;
  final String firstName;
  final String lastName;
  final bool isActive;
  final List<int> organizationDepartmentRolesIds;
  final List<PermissionItemModel> permissions;
  final List<String> permissionCodes;

  UserPermissionsResponseModel({
    required this.userId,
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.isActive,
    required this.organizationDepartmentRolesIds,
    required this.permissions,
    required this.permissionCodes,
  });

  factory UserPermissionsResponseModel.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(
      json['data'] as Map? ?? (json['user_id'] != null ? json : const {}),
    );

    final rawCodes = data['permission_codes'] as List<dynamic>? ?? [];
    final permissionCodes = rawCodes.map((e) => e.toString().trim()).toList();

    final rawPermissions = data['permissions'] as List<dynamic>? ?? [];
    final permissions = rawPermissions
        .whereType<Map>()
        .map((p) => PermissionItemModel.fromJson(Map<String, dynamic>.from(p)))
        .toList();

    final rawRoleIds =
        data['organization_department_roles_ids'] as List<dynamic>? ?? [];
    final roleIds = rawRoleIds
        .map((e) => int.tryParse(e.toString()) ?? 0)
        .where((id) => id > 0)
        .toList();

    return UserPermissionsResponseModel(
      userId: int.tryParse(data['user_id']?.toString() ?? '') ?? 0,
      userName: data['userName']?.toString() ?? '',
      firstName: data['first_name']?.toString() ?? '',
      lastName: data['last_name']?.toString() ?? '',
      isActive: data['is_active'] == true,
      organizationDepartmentRolesIds: roleIds,
      permissions: permissions,
      permissionCodes: permissionCodes,
    );
  }
}

class PermissionItemModel {
  final int id;
  final String name;
  final String code;
  final String type;

  PermissionItemModel({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
  });

  factory PermissionItemModel.fromJson(Map<String, dynamic> json) {
    return PermissionItemModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }
}
