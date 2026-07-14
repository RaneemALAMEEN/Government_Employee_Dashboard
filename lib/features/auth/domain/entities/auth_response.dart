import 'user.dart';
import 'user_role.dart';

class AuthResponse {
  final User user;
  final List<UserRole> roles;
  final List<int> departmentIds;
  final String token;
  final String refreshToken;

  AuthResponse({
    required this.user,
    required this.roles,
    required this.departmentIds,
    required this.token,
    required this.refreshToken,
  });
}
