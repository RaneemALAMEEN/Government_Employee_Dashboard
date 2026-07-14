import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _tokenKey = "token";
  static const _refreshTokenKey = "refresh_token";
  static const _roleKey = "user_role";
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
  Future<void> writeRole(String role) async {
    await _storage.write(key: _roleKey, value: role);
  }

  Future<String?> readRole() async {
    return await _storage.read(key: _roleKey);
  }

  Future<void> deleteRole() async {
    await _storage.delete(key: _roleKey);
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
    await deleteDepartmentIds();
  }
}
