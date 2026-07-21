import '../theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../core/di/injection.dart';
import '../../core/services/session_service.dart';
import '../../features/notifications/presentation/bloc/notifications_bloc.dart';
import '../../features/notifications/presentation/bloc/notifications_state.dart';
import '../../features/notifications/presentation/widgets/notification_widgets.dart';
import '../theme/app_colors.dart';

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
                const _SearchBox(),
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

  @override
  Widget build(BuildContext context) {
    return Row(
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
                valueListenable: getIt<SessionService>().currentUserNotifier,
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
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 256,
      height: 42,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextField(
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: 'بحث في المعاملات...',
            prefixIcon: const Icon(LucideIcons.search, size: 18),
            filled: true,
            fillColor: AppColors.goldLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.gold.withValues(alpha: 0.45),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.gold.withValues(alpha: 0.45),
              ),
            ),
          ),
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

  void _closePanel() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _togglePanel() {
    if (_overlayEntry != null) {
      _closePanel();
      return;
    }

    final notificationsBloc = context.read<NotificationsBloc>();
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
              child: BlocProvider.value(
                value: notificationsBloc,
                child: QuickNotificationsPanel(
                  onClose: _closePanel,
                  onViewAll: () {
                    _closePanel();
                    context.push('/notifications');
                  },
                  onNotificationTap: (notification) {
                    handleNotificationTap(
                      context,
                      notification,
                      beforeOpeningDetails: _closePanel,
                    );
                  },
                ),
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
    _closePanel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: BlocBuilder<NotificationsBloc, NotificationsState>(
        buildWhen: (previous, current) =>
            previous.unreadCount != current.unreadCount,
        builder: (context, state) => MouseRegion(
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
              if (state.unreadCount > 0)
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
                      state.unreadCount > 99
                          ? '99+'
                          : state.unreadCount.toString(),
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
