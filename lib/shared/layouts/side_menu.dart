import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:government_employee_dashboard/core/di/injection.dart';
import 'package:government_employee_dashboard/core/storage/secure_storage_service.dart';

import '../theme/app_colors.dart';

class SideMenu extends StatelessWidget {
  final double width;

  const SideMenu({
    super.key,
    this.width = 270,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          left: BorderSide(
            color: AppColors.charcoal.withOpacity(0.10),
            width: 1.2,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 130,
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.fromLTRB(18, 30, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      'مديرية التربية',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: AppColors.forest,
                        fontSize: 22,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      'ريف دمشق',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: AppColors.goldDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _RoleBadge(),
                  ),
                ],
              ),
            ),
          ),
          Divider(
            height: 1,
            thickness: 1.2,
            color: AppColors.charcoal.withOpacity(0.10),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
              children: const [
                _SidebarItem(
                  icon: Icons.home_outlined,
                  title: 'الرئيسية',
                  route: '/dashboard',
                ),
                _SidebarItem(
                  icon: Icons.description_outlined,
                  title: 'معاملاتي',
                  route: '/transactions',
                ),
                _SidebarItem(
                  icon: Icons.description_outlined,
                  title: 'معاملات داخلية',
                  route: '/internal-transactions',
                ),
                _SidebarItem(
                  icon: Icons.people_outline,
                  title: 'الموظفين',
                  route: '/employees',
                ),
                _SidebarItem(
                  icon: Icons.chat_bubble_outline,
                  title: 'الشكاوى',
                  route: '/complaints',
                ),
                _SidebarItem(
                  icon: Icons.account_tree_outlined,
                  title: 'إعداد سير العمل',
                  route: '/workflow',
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1.2,
            color: AppColors.charcoal.withOpacity(0.10),
          ),
          InkWell(
            onTap: () async {
              await getIt<SecureStorageService>().clear();

              if (context.mounted) {
                context.go('/login');
              }
            },
            child: SizedBox(
              height: 72,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: const [
                    Icon(Icons.logout, color: AppColors.umber, size: 22),
                    SizedBox(width: 12),
                    Text(
                      'تسجيل خروج',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1,
                        color: AppColors.umber,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.forestLight.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'رئيس الدائرة',
        style: TextStyle(
          fontSize: 10,
          height: 1,
          color: AppColors.forest,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String route;

  const _SidebarItem({
    required this.icon,
    required this.title,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final selected = location == route;

    return InkWell(
      onTap: () {
        final router = GoRouter.maybeOf(context);
        if (router != null && !selected) {
          router.go(route);
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 54,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: selected ? AppColors.goldLight : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(
              icon,
              size: 22,
              color: selected ? AppColors.forest : AppColors.charcoalDark,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppColors.forest : AppColors.charcoalDark,
                ),
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 10),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.forest,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
