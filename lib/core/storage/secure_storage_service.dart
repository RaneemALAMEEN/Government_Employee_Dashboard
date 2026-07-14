import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/data/models/user_model.dart';
import '../../features/auth/data/models/user_role_model.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _tokenKey = "token";
  static const _refreshTokenKey = "refresh_token";
  static const _roleKey = "user_role";
  static const _rolesListKey = "user_roles_list";
  static const _userKey = "user_details";
  static const _departmentIdsKey = "department_ids";

  // ===== Access token =====
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null || token.isEmpty) {
      return null;
    }
    return token;
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // ===== Refresh token =====
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  // ===== Active User Role =====
  Future<void> writeRole(UserRoleModel role) async {
    await _storage.write(key: _roleKey, value: jsonEncode(role.toJson()));
  }

  Future<UserRoleModel?> readRole() async {
    final roleStr = await _storage.read(key: _roleKey);
    if (roleStr != null && roleStr.isNotEmpty) {
      return UserRoleModel.fromJson(
        jsonDecode(roleStr) as Map<String, dynamic>,
      );
    }
    return null;
  }

  Future<void> deleteRole() async {
    await _storage.delete(key: _roleKey);
  }

  // ===== User Roles List =====
  Future<void> writeRoles(List<UserRoleModel> roles) async {
    final rolesList = roles.map((e) => e.toJson()).toList();
    await _storage.write(key: _rolesListKey, value: jsonEncode(rolesList));
  }

  Future<List<UserRoleModel>?> readRoles() async {
    final rolesStr = await _storage.read(key: _rolesListKey);
    if (rolesStr != null && rolesStr.isNotEmpty) {
      final rolesList = jsonDecode(rolesStr) as List<dynamic>;
      return rolesList
          .map((e) => UserRoleModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return null;
  }

  Future<void> deleteRoles() async {
    await _storage.delete(key: _rolesListKey);
  }

  // ===== User Details =====
  Future<void> writeUser(UserModel user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  Future<UserModel?> readUser() async {
    final userStr = await _storage.read(key: _userKey);
    if (userStr != null && userStr.isNotEmpty) {
      return UserModel.fromJson(
        jsonDecode(userStr) as Map<String, dynamic>,
      );
    }
    return null;
  }

  Future<void> deleteUser() async {
    await _storage.delete(key: _userKey);
  }

  // ===== Authorized departments =====
  Future<void> saveDepartmentIds(List<int> departmentIds) async {
    await _storage.write(
      key: _departmentIdsKey,
      value: departmentIds.join(','),
    );
  }

  Future<String?> getDepartmentIds() async {
    final departmentIds = await _storage.read(key: _departmentIdsKey);
    if (departmentIds == null || departmentIds.trim().isEmpty) {
      return null;
    }
    return departmentIds;
  }

  Future<void> deleteDepartmentIds() async {
    await _storage.delete(key: _departmentIdsKey);
  }

  // ===== Both tokens =====
  Future<void> saveTokens({
    required String token,
    required String refreshToken,
  }) async {
    await saveToken(token);
    await saveRefreshToken(refreshToken);
  }

  /// Wipe all auth tokens (logout / refresh failure).
  Future<void> clear() async {
    await deleteToken();
    await deleteRefreshToken();
    await deleteRole();
    await deleteRoles();
    await deleteUser();
    await deleteDepartmentIds();
  }
}
