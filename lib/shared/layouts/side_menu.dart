import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
      const _MenuItem(LucideIcons.edit3, 'مسوداتي', '/drafts', badge: 4),
      const _MenuItem(LucideIcons.users, 'الموظفين', '/employees'),
      const _MenuItem(LucideIcons.messageSquare, 'الشكاوى', '/complaints'),
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
                      const Text(
                        'مديرية التربية',
                        style: TextStyle(
                          fontSize: 20,
                          height: 1.15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.forest,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'ريف دمشق',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1,
                          fontWeight: FontWeight.w400,
                          color: AppColors.goldDark,
                        ),
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
                              style: const TextStyle(
                                fontSize: 10,
                                height: 1,
                                color: AppColors.forest,
                                fontWeight: FontWeight.w500,
                              ),
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
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
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
                                ? const Row(
                                    textDirection: TextDirection.rtl,
                                    children: [
                                      Icon(LucideIcons.refreshCw, color: AppColors.umber, size: 20),
                                      SizedBox(width: 12),
                                      Text(
                                        'تغيير الدور',
                                        style: TextStyle(
                                          fontSize: 15,
                                          height: 1,
                                          color: AppColors.umber,
                                          fontWeight: FontWeight.w500,
                                        ),
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
                                ? const Row(
                                    textDirection: TextDirection.rtl,
                                    children: [
                                      Icon(LucideIcons.logOut, color: AppColors.umber, size: 20),
                                      SizedBox(width: 12),
                                      Text(
                                        'تسجيل الخروج',
                                        style: TextStyle(
                                          fontSize: 15,
                                          height: 1,
                                          color: AppColors.umber,
                                          fontWeight: FontWeight.w500,
                                        ),
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
                          style: TextStyle(
                            fontSize: 15,
                            height: 1,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? AppColors.forest : AppColors.charcoalDark,
                          ),
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
                            style: const TextStyle(
                              fontSize: 11,
                              height: 1,
                              fontWeight: FontWeight.w600,
                              color: AppColors.forest,
                            ),
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