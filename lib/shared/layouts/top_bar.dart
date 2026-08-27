import '../theme/app_text_styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../core/di/injection.dart';
import '../../core/services/session_service.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../features/auth/presentation/widgets/change_pin_dialog.dart';
import '../../features/notifications/presentation/bloc/notifications_bloc.dart';
import '../../features/notifications/presentation/bloc/notifications_event.dart';
import '../../features/notifications/presentation/bloc/notifications_state.dart';
import '../../features/notifications/presentation/widgets/notification_widgets.dart';
import '../theme/app_colors.dart';
import '../widgets/app_confirmation_dialog.dart';
import '../widgets/global_search_box.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showSearch = constraints.maxWidth > 500;
          return Row(
            children: [
              if (showSearch) ...[
                const GlobalSearchBox(),
                const SizedBox(width: 14),
              ],
              const _NotificationButton(),
              const Spacer(),
              const _UserInfo(),
            ],
          );
        },
      ),
    );
  }
}

class _UserInfo extends StatelessWidget {
  const _UserInfo();

  void _handleSelectMenu(BuildContext context, String value) async {
    if (value == 'change_pin') {
      await ChangePinDialog.show(context);
    } else if (value == 'lock_app') {
      context.go('/pin-unlock');
    } else if (value == 'logout') {
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
      if (loggedOut == true && context.mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) => _handleSelectMenu(context, value),
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      tooltip: 'خيارات الحساب والإعدادات',
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'change_pin',
          child: Row(
            children: [
              const Icon(
                LucideIcons.keyRound,
                size: 18,
                color: AppColors.forest,
              ),
              const SizedBox(width: 10),
              Text(
                'تغيير رمز PIN',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: AppTextStyles.medium,
                  color: AppColors.charcoal,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'lock_app',
          child: Row(
            children: [
              const Icon(
                LucideIcons.lock,
                size: 18,
                color: AppColors.charcoalDark,
              ),
              const SizedBox(width: 10),
              Text(
                'قفل التطبيق',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: AppTextStyles.medium,
                  color: AppColors.charcoal,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              const Icon(
                LucideIcons.logOut,
                size: 18,
                color: AppColors.error,
              ),
              const SizedBox(width: 10),
              Text(
                'تسجيل الخروج',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: AppTextStyles.medium,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ],
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.forest,
              child: Icon(LucideIcons.user, color: AppColors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValueListenableBuilder(
                    valueListenable:
                        getIt<SessionService>().currentUserNotifier,
                    builder: (context, user, _) {
                      return Text(
                        user?.userName ?? 'مستخدم',
                        style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: AppTextStyles.semiBold,
                            color: AppColors.charcoalDark,
                            height: 1.1),
                      );
                    }),
                const SizedBox(height: 4),
                ValueListenableBuilder(
                  valueListenable: getIt<SessionService>().activeRoleNotifier,
                  builder: (context, activeRole, _) {
                    return Text(
                      activeRole?.roleName ?? 'الدور غير محدد',
                      style: AppTextStyles.labelMedium.copyWith(height: 1),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(width: 14),
            const Icon(LucideIcons.chevronDown, size: 20),
          ],
        ),
      ),
    );
  }
}

class _NotificationButton extends StatefulWidget {
  const _NotificationButton();

  @override
  State<_NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<_NotificationButton> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  late NotificationsBloc _notificationsBloc;
  bool _isClosingPanel = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notificationsBloc = context.read<NotificationsBloc>();
  }

  Future<void> _closePanel({bool preserveSession = false}) async {
    if (_overlayEntry == null || _isClosingPanel) return;
    _isClosingPanel = true;
    final closed = _notificationsBloc.stream.firstWhere(
      (state) => !state.isPopupOpen && !state.isClosingPopupAndMarkingRead,
    );
    _notificationsBloc.add(
      NotificationsPopupClosed(preserveSession: preserveSession),
    );
    await closed;
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isClosingPanel = false;
  }

  void _togglePanel() {
    if (_overlayEntry != null) {
      _closePanel();
      return;
    }

    final notificationsBloc = _notificationsBloc;
    notificationsBloc.add(const NotificationsPopupOpened());
    _overlayEntry = OverlayEntry(
      builder: (overlayContext) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _closePanel,
            ),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomCenter,
            followerAnchor: Alignment.topCenter,
            offset: const Offset(0, 8),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: QuickNotificationsPanel(
                bloc: notificationsBloc,
                onClose: _closePanel,
                onViewAll: () async {
                  await _closePanel(preserveSession: true);
                  if (!mounted) return;
                  context.push('/notifications');
                },
                onNotificationTap: (notification) async {
                  await _closePanel();
                  if (!mounted) return;
                  handleNotificationTap(
                    context,
                    notification,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  void dispose() {
    if (_overlayEntry != null) {
      _notificationsBloc.add(const NotificationsPopupClosed());
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      final bloc = context.read<NotificationsBloc>();
      debugPrint(
        '[NotificationsBloc][Topbar] instance=${identityHashCode(bloc)}',
      );
    }
    return CompositedTransformTarget(
      link: _layerLink,
      child: BlocSelector<NotificationsBloc, NotificationsState, int>(
        selector: (state) => state.unreadCount,
        builder: (context, unreadCount) => MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Material(
                color: AppColors.forestLight.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: _togglePanel,
                  borderRadius: BorderRadius.circular(8),
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(
                      LucideIcons.bell,
                      color: AppColors.forest,
                      size: 20,
                    ),
                  ),
                ),
              ),
              if (unreadCount > 0)
                Positioned(
                  top: -5,
                  right: -7,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 18),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.surface, width: 1.5),
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.surface,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
