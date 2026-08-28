import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../core/di/injection.dart';
import '../../core/services/session_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class PermissionDeniedCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const PermissionDeniedCard({
    super.key,
    required this.title,
    required this.description,
    this.icon = LucideIcons.shieldAlert,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 42),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: .25),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 42, color: AppColors.goldDark),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.charcoalDark,
                  fontWeight: AppTextStyles.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.goldDark,
                ),
              ),
            ],
          ),
        ),
      );
}

class RoutePermissionGuard extends StatelessWidget {
  final String? permission;
  final Iterable<String>? anyPermissions;
  final Iterable<String>? allPermissions;
  final Widget child;
  final String title;
  final String description;

  const RoutePermissionGuard({
    super.key,
    this.permission,
    this.anyPermissions,
    this.allPermissions,
    required this.child,
    this.title = 'غير مصرح بالوصول إلى هذه الصفحة',
    this.description =
        'حسابك لا يمتلك الصلاحيات الكافية لعرض هذه الصفحة أو تنفيذ إجراءاتها.',
  });

  @override
  Widget build(BuildContext context) {
    final session = getIt<SessionService>();

    return ValueListenableBuilder<PermissionsStatus>(
      valueListenable: session.permissionsStatusNotifier,
      builder: (context, status, _) {
        if (status == PermissionsStatus.loading) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
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

            if (!isAuthorized) {
              return Scaffold(
                backgroundColor: AppColors.background,
                body: SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: PermissionDeniedCard(
                        title: title,
                        description: description,
                      ),
                    ),
                  ),
                ),
              );
            }

            return child;
          },
        );
      },
    );
  }
}
