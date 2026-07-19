import 'dart:convert';

import '../../domain/entities/auth_response.dart';
import 'user_model.dart';
import 'user_role_model.dart';

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
    final data = Map<String, dynamic>.from(
      json['data'] as Map? ?? const {},
    );
    final token = data['token']?.toString() ?? '';
    final organizationId =
        _findOrganizationId(data) ?? _organizationIdFromToken(token);

    final roles = (data['roles'] as List<dynamic>?)
            ?.whereType<Map>()
            .map((role) {
              final roleJson = Map<String, dynamic>.from(role);
              roleJson['organization_id'] ??= organizationId;
              return UserRoleModel.fromJson(roleJson);
            })
            .toList() ??
        [];

    final userJson = Map<String, dynamic>.from(
      data['user'] as Map<String, dynamic>? ?? const {},
    );
    userJson['organization_id'] ??= organizationId ??
        (roles.isNotEmpty && roles.first.organizationId > 0
            ? roles.first.organizationId
            : null);

    return AuthResponseModel(
      user: UserModel.fromJson(userJson),
      roles: roles,
      departmentIds: roles.map((role) => role.departmentId).toSet().toList(),
      token: token,
      refreshToken: data['refreshToken']?.toString() ?? '',
    );
  }

  static int? _findOrganizationId(dynamic value) {
    if (value is Map) {
      for (final key in const ['organization_id', 'organizationId']) {
        final id = _asPositiveInt(value[key]);
        if (id != null) return id;
      }

      final organization = value['organization'];
      if (organization is Map) {
        final id = _asPositiveInt(organization['id']);
        if (id != null) return id;
      }

      for (final nested in value.values) {
        final id = _findOrganizationId(nested);
        if (id != null) return id;
      }
    } else if (value is List) {
      for (final nested in value) {
        final id = _findOrganizationId(nested);
        if (id != null) return id;
      }
    }
    return null;
  }

  static int? _organizationIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      return _findOrganizationId(payload);
    } catch (_) {
      return null;
    }
  }

  static int? _asPositiveInt(dynamic value) {
    final parsed =
        value is int ? value : int.tryParse(value?.toString().trim() ?? '');
    return parsed != null && parsed > 0 ? parsed : null;
  }
}
