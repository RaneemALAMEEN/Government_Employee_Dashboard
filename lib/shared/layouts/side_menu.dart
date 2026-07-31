import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../core/di/injection.dart';
import '../../core/services/session_service.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../features/auth/domain/entities/user_role.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_confirmation_dialog.dart';

const _sidebarDividerColor = Color(0xFFE9ECEF);
const _sidebarSelectedColor = Color(0xFFF4F2E8);

class AppSidebar extends StatefulWidget {
  final bool isCollapsed;
  final bool showLabels;
  final VoidCallback onToggleCollapse;

  const AppSidebar({
    super.key,
    required this.isCollapsed,
    required this.showLabels,
    required this.onToggleCollapse,
  });

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _headerController;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;

  static const _items = <SidebarNavItem>[
    SidebarNavItem(LucideIcons.home, 'الرئيسية', '/dashboard'),
    SidebarNavItem(LucideIcons.fileText, 'معاملاتي', '/my-transactions'),
    SidebarNavItem(
      LucideIcons.inbox,
      'المعاملات الداخلية',
      '/internal-transactions',
    ),
    SidebarNavItem(
      LucideIcons.building,
      'معاملات الدائرة',
      '/department-transactions',
    ),
    SidebarNavItem(
      LucideIcons.workflow,
      'إدارة المعاملات والشكاوى',
      '/directorate-process-management',
    ),
    SidebarNavItem(
      LucideIcons.chartNoAxesCombined,
      'الإحصائيات',
      '/statistics',
    ),
    SidebarNavItem(
      LucideIcons.network,
      'الهيكل التنظيمي',
      '/organization-hierarchy',
    ),
    SidebarNavItem(
      LucideIcons.shieldCheck,
      'فحص الوثائق',
      '/document-quality-checker',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    final curve = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    );
    _headerFade = curve;
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -.25),
      end: Offset.zero,
    ).animate(curve);
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final activeRoute = findActiveSidebarRoute(
      location,
      _items.map((item) => item.route),
    );

    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.surface),
      child: Column(
        children: [
          FadeTransition(
            opacity: _headerFade,
            child: SlideTransition(
              position: _headerSlide,
              child: _SidebarHeader(
                showLabels: widget.showLabels,
                onToggleCollapse: widget.onToggleCollapse,
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: _sidebarDividerColor),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 14),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return SidebarItem(
                  item: item,
                  order: index,
                  selected: item.route == activeRoute,
                  showLabel: widget.showLabels,
                );
              },
            ),
          ),
          const Divider(height: 1, thickness: 1, color: _sidebarDividerColor),
          Padding(
            padding: EdgeInsets.fromLTRB(
              widget.isCollapsed ? 10 : 18,
              12,
              widget.isCollapsed ? 10 : 18,
              8,
            ),
            child: _SidebarAction(
              icon: LucideIcons.refreshCw,
              label: 'تغيير الدور',
              compact: !widget.showLabels,
              onTap: () => _changeRole(context),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              widget.isCollapsed ? 10 : 18,
              0,
              widget.isCollapsed ? 10 : 18,
              18,
            ),
            child: _SidebarAction(
              icon: LucideIcons.logOut,
              label: 'تسجيل الخروج',
              compact: !widget.showLabels,
              emphasized: true,
              onTap: () => _logout(context),
            ),
          ),
        ],
      ),
    );
  }

  void _changeRole(BuildContext context) {
    getIt<SessionService>().cycleRole();
    final newRole = getIt<SessionService>().activeRoleNotifier.value;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم تغيير الدور إلى: ${newRole?.roleName ?? ""}',
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: AppTextStyles.semiBold,
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final loggedOut = await showAppConfirmationDialog(
      context,
      title: 'تسجيل الخروج',
      message: 'هل تريد تسجيل الخروج من النظام؟',
      confirmText: 'تسجيل الخروج',
      cancelText: 'إلغاء',
      icon: LucideIcons.logOut,
      isDestructive: true,
      failureMessage: 'تعذر تسجيل الخروج، حاول مرة أخرى',
      onConfirm: getIt<SecureStorageService>().clear,
    );
    if (loggedOut == true && context.mounted) context.go('/login');
  }
}

class _SidebarHeader extends StatelessWidget {
  final bool showLabels;
  final VoidCallback onToggleCollapse;

  const _SidebarHeader({
    required this.showLabels,
    required this.onToggleCollapse,
  });

  @override
  Widget build(BuildContext context) {
    if (!showLabels) {
      return SizedBox(
        height: 92,
        child: Center(
          child: IconButton(
            tooltip: 'توسيع القائمة',
            onPressed: onToggleCollapse,
            icon: const Icon(LucideIcons.menu, color: AppColors.primary),
          ),
        ),
      );
    }
    return SizedBox(
      height: 128,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 28, 22, 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مديرية التربية',
                    style: AppTextStyles.headlineLarge.copyWith(
                      fontSize: 22,
                      fontWeight: AppTextStyles.black,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ValueListenableBuilder<UserRole?>(
                    valueListenable: getIt<SessionService>().activeRoleNotifier,
                    builder: (context, role, _) => Text(
                      role?.departmentName ?? 'ريف دمشق',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: AppTextStyles.medium,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'طي القائمة',
              visualDensity: VisualDensity.compact,
              onPressed: onToggleCollapse,
              icon: const Icon(
                LucideIcons.chevronLeft,
                color: AppColors.primary,
                size: 21,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SidebarItem extends StatefulWidget {
  final SidebarNavItem item;
  final int order;
  final bool selected;
  final bool showLabel;

  const SidebarItem({
    super.key,
    required this.item,
    required this.order,
    required this.selected,
    required this.showLabel,
  });

  @override
  State<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    final curve = CurvedAnimation(
      parent: _entrance,
      curve: Curves.easeOutCubic,
    );
    _fade = curve;
    _slide = Tween<Offset>(
      begin: const Offset(.18, 0),
      end: Offset.zero,
    ).animate(curve);
    Future<void>.delayed(
      Duration(milliseconds: 60 + widget.order * 55),
      () {
        if (mounted) _entrance.forward();
      },
    );
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final background = selected
        ? _sidebarSelectedColor
        : _hovered
            ? _sidebarSelectedColor.withValues(alpha: .65)
            : Colors.transparent;
    final foreground = selected ? AppColors.primary : AppColors.textPrimary;
    final content = Row(
      textDirection: TextDirection.rtl,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
          width: 3,
          height: selected ? 26 : 0,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        if (widget.showLabel) const SizedBox(width: 8),
        Expanded(
          child: Row(
            mainAxisAlignment: !widget.showLabel
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              AnimatedScale(
                scale: selected ? 1.12 : (_hovered ? 1.06 : 1),
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Icon(
                    widget.item.icon,
                    key: ValueKey(selected),
                    size: 21,
                    color: foreground,
                  ),
                ),
              ),
              if (widget.showLabel) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 14.5,
                      height: 1.2,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: foreground,
                    ),
                    child: Text(
                      widget.item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _SidebarTooltip(
            visible: !widget.showLabel,
            message: widget.item.title,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => _hovered = true),
              onExit: (_) => setState(() => _hovered = false),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => GoRouter.maybeOf(context)?.go(widget.item.route),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  height: 50,
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.showLabel ? 12 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: content,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarAction extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool compact;
  final bool emphasized;
  final VoidCallback onTap;

  const _SidebarAction({
    required this.icon,
    required this.label,
    required this.compact,
    required this.onTap,
    this.emphasized = false,
  });

  @override
  State<_SidebarAction> createState() => _SidebarActionState();
}

class _SidebarActionState extends State<_SidebarAction> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final active = _hovered || _pressed;
    final foreground = active ? AppColors.error : AppColors.textSecondary;
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth =
            constraints.hasBoundedWidth ? constraints.maxWidth : 180.0;
        final buttonWidth = widget.compact ? 48.0 : availableWidth;

        return _SidebarTooltip(
          visible: widget.compact,
          message: widget.label,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() {
              _hovered = false;
              _pressed = false;
            }),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) => setState(() => _pressed = true),
              onTapUp: (_) => setState(() => _pressed = false),
              onTapCancel: () => setState(() => _pressed = false),
              onTap: widget.onTap,
              child: AnimatedScale(
                scale: _pressed ? .985 : 1,
                duration: const Duration(milliseconds: 110),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  width: buttonWidth,
                  height: widget.compact ? 48 : 52,
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.compact ? 0 : 16,
                  ),
                  decoration: BoxDecoration(
                    color: _pressed
                        ? AppColors.error.withValues(alpha: .12)
                        : _hovered
                            ? AppColors.error.withValues(alpha: .08)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: active
                          ? AppColors.error.withValues(alpha: .18)
                          : _sidebarDividerColor,
                      width: 1,
                    ),
                  ),
                  child: widget.compact
                      ? Center(child: _buildIcon(active, foreground))
                      : Row(
                          children: [
                            _buildIcon(active, foreground),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 180),
                                curve: Curves.easeOutCubic,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontSize: 14.5,
                                  fontWeight: AppTextStyles.semiBold,
                                  color: foreground,
                                ),
                                child: Text(
                                  widget.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIcon(bool active, Color foreground) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: _hovered ? -3 : 0),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      builder: (_, value, child) => Transform.translate(
        offset: Offset(value, 0),
        child: child,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 160),
        child: Icon(
          widget.icon,
          key: ValueKey('${widget.emphasized}-$active'),
          color: foreground,
          size: 20,
        ),
      ),
    );
  }
}

class SidebarNavItem {
  final IconData icon;
  final String title;
  final String route;

  const SidebarNavItem(this.icon, this.title, this.route);
}

class _SidebarTooltip extends StatelessWidget {
  final bool visible;
  final String message;
  final Widget child;

  const _SidebarTooltip({
    required this.visible,
    required this.message,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return child;

    return Tooltip(
      message: message,
      waitDuration: const Duration(milliseconds: 350),
      showDuration: const Duration(seconds: 3),
      preferBelow: false,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _sidebarDividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      textStyle: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textPrimary,
        fontWeight: AppTextStyles.medium,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: child,
    );
  }
}

String? findActiveSidebarRoute(String location, Iterable<String> routes) {
  final matches = routes.where(
    (route) => location == route || location.startsWith('$route/'),
  );
  if (matches.isEmpty) return null;
  return matches.reduce(
    (current, candidate) =>
        candidate.length > current.length ? candidate : current,
  );
}

@Deprecated('Use AppSidebar instead.')
typedef SideMenu = AppSidebar;
