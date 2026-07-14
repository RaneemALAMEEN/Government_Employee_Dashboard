import '../../domain/entities/auth_response.dart';
import 'user_model.dart';

class AuthResponseModel extends AuthResponse {
  AuthResponseModel({
    required super.user,
    required super.roles,
    required super.departmentIds,
    required super.token,
    required super.refreshToken,
  });

  factory AuthResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = json['data'] as Map<String, dynamic>;
    final rolesData = data['roles'] as List? ?? [];
    final roleIds = <int>[];
    final departmentIds = <int>{};

    for (final item in rolesData) {
      if (item is int) {
        roleIds.add(item);
      } else if (item is Map) {
        final roleId = item['role_id'];
        final departmentId = item['department_id'];

        if (roleId is int) {
          roleIds.add(roleId);
        } else if (roleId is String) {
          final parsedRoleId = int.tryParse(roleId);
          if (parsedRoleId != null) roleIds.add(parsedRoleId);
        }

        if (departmentId is int) {
          departmentIds.add(departmentId);
        } else if (departmentId is String) {
          final parsedDepartmentId = int.tryParse(departmentId);
          if (parsedDepartmentId != null) departmentIds.add(parsedDepartmentId);
        }
      }
    }

    return AuthResponseModel(
      user: UserModel.fromJson(data['user']),
      roles: roleIds,
      departmentIds: departmentIds.toList(),
      token: data['token'] ?? '',
      refreshToken: data['refreshToken'] ?? '',
    );
  }
}
