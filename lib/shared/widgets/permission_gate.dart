import 'package:flutter/material.dart';

import '../../core/di/injection.dart';
import '../../core/services/session_service.dart';

/// A widget that conditionally renders [child] only if the active user possesses
/// the required permission(s).
///
/// If unauthorized, it renders [fallback] (default is [SizedBox.shrink]).
///
/// Can specify:
/// - [permission]: Single required permission code
/// - [anyPermissions]: User must have at least one permission in the list
/// - [allPermissions]: User must have all permissions in the list
class PermissionGate extends StatelessWidget {
  final String? permission;
  final Iterable<String>? anyPermissions;
  final Iterable<String>? allPermissions;
  final Widget child;
  final Widget fallback;
  final Widget? loadingWidget;

  const PermissionGate({
    super.key,
    this.permission,
    this.anyPermissions,
    this.allPermissions,
    required this.child,
    this.fallback = const SizedBox.shrink(),
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    final session = getIt<SessionService>();

    return ValueListenableBuilder<PermissionsStatus>(
      valueListenable: session.permissionsStatusNotifier,
      builder: (context, status, _) {
        if (status == PermissionsStatus.loading) {
          return loadingWidget ?? const SizedBox.shrink();
        }

        return ValueListenableBuilder<Set<String>>(
          valueListenable: session.permissionsNotifier,
          builder: (context, userPermissions, _) {
            bool isAuthorized = true;

            if (permission != null) {
              isAuthorized = userPermissions.contains(permission);
            } else if (anyPermissions != null && anyPermissions!.isNotEmpty) {
              isAuthorized = anyPermissions!.any(userPermissions.contains);
            } else if (allPermissions != null && allPermissions!.isNotEmpty) {
              isAuthorized = allPermissions!.every(userPermissions.contains);
            }

            return isAuthorized ? child : fallback;
          },
        );
      },
    );
  }
}

/// Helpful extensions for checking permissions directly within widgets.
extension PermissionContextX on BuildContext {
  /// Checks if the active user has a specific permission code.
  bool hasPermission(String code) => getIt<SessionService>().hasPermission(code);

  /// Checks if the active user has at least one of the provided permission codes.
  bool hasAnyPermission(Iterable<String> codes) =>
      getIt<SessionService>().hasAnyPermission(codes);

  /// Checks if the active user has all of the provided permission codes.
  bool hasAllPermissions(Iterable<String> codes) =>
      getIt<SessionService>().hasAllPermissions(codes);
}
