import '../theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../core/di/injection.dart';
import '../../core/services/session_service.dart';
import '../theme/app_colors.dart';
import '../../core/storage/secure_storage_service.dart';

class SideMenu extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;

  const SideMenu({
    super.key,
    required this.isCollapsed,
    required this.onToggleCollapse,
  });

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    final items = [
      const _MenuItem(LucideIcons.home, 'الرئيسية', '/dashboard'),
      const _MenuItem(LucideIcons.fileText, 'معاملاتي', '/my-transactions'),
      const _MenuItem(LucideIcons.inbox, 'المعاملات الداخلية', '/internal-transactions', badge: 12),
      const _MenuItem(LucideIcons.building, 'معاملات الدائرة', '/department-transactions'),
      const _MenuItem(LucideIcons.users, 'الموظفين', '/employees'),
      const _MenuItem(LucideIcons.messageSquare, 'الشكاوى', '/complaints'),
      const _MenuItem(LucideIcons.shieldCheck, 'فحص الوثائق', '/document-quality-checker'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
      ),
      clipBehavior: Clip.hardEdge,
      child: LayoutBuilder(
        builder: (context, viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Toggle Expand/Collapse Button
                    Align(
                      alignment: isCollapsed ? Alignment.center : Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 0 : 16),
                        child: IconButton(
                          icon: Icon(
                            isCollapsed ? LucideIcons.menu : LucideIcons.chevronLeft,
                            color: AppColors.forest,
                          ),
                          onPressed: onToggleCollapse,
                        ),
                      ),
                    ),
                    if (!isCollapsed) ...[
                      const SizedBox(height: 11),
                      Text(
                        'مديرية التربية',
                        style: AppTextStyles.headlineMedium,
                      ),
                      const SizedBox(height: 7),
                      Text(
                        'ريف دمشق',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.goldDark, height: 1),
                      ),
                      const SizedBox(height: 8),
                      ValueListenableBuilder<String>(
                        valueListenable: getIt<SessionService>().activeRoleNotifier,
                        builder: (context, activeRole, _) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.forestLight.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              activeRole,
                              style: AppTextStyles.labelSmall.copyWith(color: AppColors.forest),
                            ),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 39),
                    ...items.map((item) {
                      final isSelected = location.startsWith(item.route) &&
                          (item.route != '/' || location == '/');
                      return _SideMenuTile(
                        item: item,
                        isSelected: isSelected,
                        isCollapsed: isCollapsed,
                      );
                    }),
                    const Spacer(),
                    Container(height: 1, color: AppColors.charcoal.withOpacity(0.18)),
                    GestureDetector(
                      onTap: () {
                        getIt<SessionService>().cycleRole();
                        final newRole = getIt<SessionService>().activeRoleNotifier.value;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'تم تغيير الدور إلى: $newRole',
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                              style: AppTextStyles.bodySmall.copyWith(fontWeight: AppTextStyles.semiBold),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        height: 72,
                        padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 0 : 22),
                        color: Colors.transparent,
                        child: LayoutBuilder(
                          builder: (context, logoutConstraints) {
                            final showFullLogout = logoutConstraints.maxWidth > 150;

                            return showFullLogout
                                ? Row(
                                    textDirection: TextDirection.rtl,
                                    children: [
                                      const Icon(LucideIcons.refreshCw, color: AppColors.umber, size: 20),
                                      const SizedBox(width: 12),
                                      Text(
                                        'تغيير الدور',
                                        style: AppTextStyles.bodyLarge.copyWith(fontWeight: AppTextStyles.medium, color: AppColors.umber, height: 1),
                                      ),
                                    ],
                                  )
                                : const Center(
                                    child: Icon(
                                      LucideIcons.refreshCw,
                                      color: AppColors.umber,
                                      size: 20,
                                    ),
                                  );
                          },
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await getIt<SecureStorageService>().clear();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
                      child: Container(
                        height: 72,
                        padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 0 : 22),
                        color: Colors.transparent,
                        child: LayoutBuilder(
                          builder: (context, logoutConstraints) {
                            final showFullLogout = logoutConstraints.maxWidth > 150;

                            return showFullLogout
                                ? Row(
                                    textDirection: TextDirection.rtl,
                                    children: [
                                      const Icon(LucideIcons.logOut, color: AppColors.umber, size: 20),
                                      const SizedBox(width: 12),
                                      Text(
                                        'تسجيل الخروج',
                                        style: AppTextStyles.bodyLarge.copyWith(fontWeight: AppTextStyles.medium, color: AppColors.umber, height: 1),
                                      ),
                                    ],
                                  )
                                : const Center(
                                    child: Icon(
                                      LucideIcons.logOut,
                                      color: AppColors.umber,
                                      size: 20,
                                    ),
                                  );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SideMenuTile extends StatelessWidget {
  final _MenuItem item;
  final bool isSelected;
  final bool isCollapsed;

  const _SideMenuTile({
    required this.item,
    required this.isSelected,
    required this.isCollapsed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.go(item.route);
      },
      child: Container(
        height: 49,
        margin: EdgeInsets.symmetric(
          horizontal: isCollapsed ? 8 : 16,
          vertical: 7,
        ),
        padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 0 : 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.goldLight : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: LayoutBuilder(
          builder: (context, tileConstraints) {
            final showFullRow = !isCollapsed && tileConstraints.maxWidth > 100;

            return showFullRow
                ? Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Icon(
                        item.icon,
                        size: 20,
                        color: isSelected ? AppColors.forest : AppColors.charcoal,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          style: AppTextStyles.bodyLarge.copyWith(fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? AppColors.forest : AppColors.charcoalDark, height: 1),
                        ),
                      ),
                      if (item.badge != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.forestLight.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${item.badge}',
                            style: AppTextStyles.labelMedium.copyWith(fontWeight: AppTextStyles.semiBold, color: AppColors.forest, height: 1),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (isSelected)
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.forest,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  )
                : Center(
                    child: Icon(
                      item.icon,
                      size: 20,
                      color: isSelected ? AppColors.forest : AppColors.charcoal,
                    ),
                  );
          },
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String route;
  final int? badge;

  const _MenuItem(this.icon, this.title, this.route, {this.badge});
}

