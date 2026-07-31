import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../domain/entities/notification_entity.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import '../bloc/notifications_state.dart';

class NotificationCard extends StatefulWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;
  final bool isMarkingRead;
  final bool isOpened;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    this.isMarkingRead = false,
    this.isOpened = false,
  });

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.notification;
    final color = notificationTypeColor(item.type);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 170),
        transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
        decoration: BoxDecoration(
          color: widget.isOpened
              ? AppColors.surface
              : item.isRead
                  ? AppColors.surface.withValues(alpha: .96)
                  : AppColors.lightPrimary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hovered
                ? AppColors.primary.withValues(alpha: .38)
                : AppColors.border.withValues(alpha: item.isRead ? .25 : .42),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(
                alpha: _hovered ? .08 : .025,
              ),
              blurRadius: _hovered ? 16 : 8,
              offset: Offset(0, _hovered ? 6 : 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      notificationTypeIcon(item.type),
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title.isEmpty ? 'إشعار' : item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.titleSmall.copyWith(
                                  fontWeight: widget.isOpened
                                      ? FontWeight.w400
                                      : item.isRead
                                          ? FontWeight.w600
                                          : FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              formatRelativeNotificationTime(item.createdAt),
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        if (item.message.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text(
                            item.message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (widget.isMarkingRead) ...[
                    const SizedBox(width: 10),
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ] else if (!item.isRead) ...[
                    const SizedBox(width: 10),
                    Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.only(top: 7),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QuickNotificationsPanel extends StatefulWidget {
  final NotificationsBloc bloc;
  final VoidCallback onClose;
  final VoidCallback onViewAll;
  final ValueChanged<NotificationEntity> onNotificationTap;

  const QuickNotificationsPanel({
    super.key,
    required this.bloc,
    required this.onClose,
    required this.onViewAll,
    required this.onNotificationTap,
  });

  @override
  State<QuickNotificationsPanel> createState() =>
      _QuickNotificationsPanelState();
}

class _QuickNotificationsPanelState extends State<QuickNotificationsPanel> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMoreNearBottom);
  }

  void _loadMoreNearBottom() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      widget.bloc.add(const LoadMorePopupNotifications());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      debugPrint(
        '[NotificationsBloc][Popup] instance=${identityHashCode(widget.bloc)}',
      );
    }
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 410,
          maxWidth: 440,
          maxHeight: 520,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withValues(alpha: .34)),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: .15),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: BlocBuilder<NotificationsBloc, NotificationsState>(
          bloc: widget.bloc,
          builder: (context, state) {
            final recent = state.popupItems;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 13, 16, 11),
                  child: Row(
                    children: [
                      const Text(
                        'الإشعارات',
                        style: AppTextStyles.titleMedium,
                      ),
                      const Spacer(),
                      if (state.isClosingPopupAndMarkingRead) ...[
                        const SizedBox(
                          width: 13,
                          height: 13,
                          child: CircularProgressIndicator(strokeWidth: 1.8),
                        ),
                        const SizedBox(width: 6),
                      ],
                      if (state.unreadCount > 0)
                        Text(
                          '${state.unreadCount} غير مقروءة',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: state.isClosingPopupAndMarkingRead
                            ? null
                            : widget.onClose,
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(LucideIcons.x, size: 18),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  color: AppColors.border.withValues(alpha: .25),
                ),
                if (state.syncErrorMessage != null)
                  InkWell(
                    onTap: () => widget.bloc.add(
                      const FlushVisibleNotificationsRead(),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 7,
                      ),
                      child: Text(
                        '${state.syncErrorMessage} — إعادة المحاولة',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                Flexible(
                  child: Builder(
                    builder: (_) {
                      if (state.isPopupLoading && recent.isEmpty) {
                        return const NotificationSkeletonList(
                          itemCount: 3,
                          compact: true,
                        );
                      }
                      if (state.popupErrorMessage != null && recent.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'تعذر تحميل الإشعارات',
                                style: AppTextStyles.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => widget.bloc
                                    .add(const NotificationsPopupOpened()),
                                child: const Text('إعادة المحاولة'),
                              ),
                            ],
                          ),
                        );
                      }
                      if (recent.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(28),
                          child: Text(
                            'لا توجد إشعارات حالياً',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        controller: _scrollController,
                        shrinkWrap: true,
                        physics: recent.length <= 5
                            ? const NeverScrollableScrollPhysics()
                            : const ClampingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        itemCount:
                            recent.length + (state.isPopupLoadingMore ? 1 : 0),
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: AppColors.border.withValues(alpha: .18),
                        ),
                        itemBuilder: (_, index) {
                          if (index == recent.length) {
                            return const Padding(
                              padding: EdgeInsets.all(12),
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            );
                          }
                          final item = recent[index];
                          return _QuickNotificationTile(
                            notification: item,
                            isNewInPopupSession:
                                state.popupSessionNewIds.contains(item.id),
                            isOpened:
                                state.openedNotificationIds.contains(item.id),
                            isMarkingRead:
                                state.markingReadIds.contains(item.id),
                            onTap: () => widget.onNotificationTap(item),
                          );
                        },
                      );
                    },
                  ),
                ),
                Divider(
                  height: 1,
                  color: AppColors.border.withValues(alpha: .25),
                ),
                TextButton(
                  onPressed: widget.onViewAll,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text('عرض جميع الإشعارات'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _QuickNotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;
  final bool isMarkingRead;
  final bool isOpened;
  final bool isNewInPopupSession;

  const _QuickNotificationTile({
    required this.notification,
    required this.onTap,
    required this.isMarkingRead,
    required this.isOpened,
    required this.isNewInPopupSession,
  });

  @override
  Widget build(BuildContext context) {
    final color = notificationTypeColor(notification.type);
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isNewInPopupSession
            ? AppColors.lightPrimary.withValues(alpha: .55)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              notificationTypeIcon(notification.type),
              color: color,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title.isEmpty ? 'إشعار' : notification.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: isNewInPopupSession
                          ? FontWeight.w700
                          : isOpened
                              ? FontWeight.w400
                              : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isNewInPopupSession) ...[
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
            ],
            if (isMarkingRead)
              const SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Text(
                formatRelativeNotificationTime(notification.createdAt),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class NotificationSkeletonList extends StatefulWidget {
  final int itemCount;
  final bool compact;

  const NotificationSkeletonList({
    super.key,
    this.itemCount = 6,
    this.compact = false,
  });

  @override
  State<NotificationSkeletonList> createState() =>
      _NotificationSkeletonListState();
}

class _NotificationSkeletonListState extends State<NotificationSkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (_, child) => Opacity(
          opacity: .45 + _controller.value * .35,
          child: child,
        ),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(widget.compact ? 10 : 0),
          itemCount: widget.itemCount,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, __) => Container(
            height: widget.compact ? 62 : 88,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.border.withValues(alpha: .25),
              ),
            ),
          ),
        ),
      );
}

class NotificationsMessageState extends StatelessWidget {
  final String message;
  final bool isError;
  final VoidCallback? onRetry;

  const NotificationsMessageState({
    super.key,
    required this.message,
    this.isError = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 220),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isError ? LucideIcons.triangleAlert : LucideIcons.bellOff,
              size: 36,
              color: (isError ? AppColors.error : AppColors.primary)
                  .withValues(alpha: .72),
            ),
            const SizedBox(height: 11),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(LucideIcons.refreshCw, size: 17),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ],
        ),
      );
}

Future<void> showNotificationDetailsDialog(
  BuildContext context,
  NotificationEntity notification,
) =>
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            notification.title.isEmpty ? 'إشعار' : notification.title,
            style: AppTextStyles.headlineSmall,
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SelectableText(
                  notification.message,
                  style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                ),
                const SizedBox(height: 18),
                Text(
                  formatNotificationDateTime(notification.createdAt),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );

Future<void> handleNotificationTap(
  BuildContext context,
  NotificationEntity notification, {
  VoidCallback? beforeOpeningDetails,
}) async {
  if (kDebugMode) {
    debugPrint(
      '[Notifications] tapped notification id=${notification.id}, '
      'isRead=${notification.isRead}',
    );
  }
  final bloc = context.read<NotificationsBloc>();
  final currentItems = [...bloc.state.items, ...bloc.state.popupItems];
  final currentIndex =
      currentItems.indexWhere((item) => item.id == notification.id);
  if (currentIndex >= 0) {
    notification = currentItems[currentIndex];
  }
  bloc.add(NotificationOpened(notificationId: notification.id));
  var itemToOpen = notification;

  if (!notification.isRead) {
    if (bloc.state.markingReadIds.contains(notification.id)) {
      final result = await bloc.stream.firstWhere(
        (state) => !state.markingReadIds.contains(notification.id),
      );
      if (!context.mounted) return;
      itemToOpen = [...result.items, ...result.popupItems].firstWhere(
        (item) => item.id == notification.id,
        orElse: () => notification,
      );
      if (!itemToOpen.isRead) return;
      beforeOpeningDetails?.call();
      if (!context.mounted) return;
      await showNotificationDetailsDialog(context, itemToOpen);
      return;
    }
    if (bloc.state.markingReadNotificationId != null) return;
    bloc.add(MarkNotificationAsRead(notificationId: notification.id));

    final result = await bloc.stream.firstWhere(
      (state) =>
          state.markingReadNotificationId == null &&
          (state.items.any(
                (item) => item.id == notification.id && item.isRead,
              ) ||
              state.popupItems.any(
                (item) => item.id == notification.id && item.isRead,
              ) ||
              state.markReadErrorNotificationId == notification.id),
    );
    if (!context.mounted) return;
    if (result.markReadErrorNotificationId == notification.id) {
      AppSnackBar.show(
        context,
        message: 'تعذر تعليم الإشعار كمقروء',
        isError: true,
      );
      return;
    }
    itemToOpen = [...result.items, ...result.popupItems].firstWhere(
      (item) => item.id == notification.id,
      orElse: () => notification.copyWith(isRead: true),
    );
  }

  beforeOpeningDetails?.call();
  if (!context.mounted) return;
  await showNotificationDetailsDialog(context, itemToOpen);
}

IconData notificationTypeIcon(String type) {
  switch (type.toLowerCase()) {
    case 'transaction_rejected':
      return LucideIcons.circleX;
    case 'transaction_approved':
      return LucideIcons.circleCheck;
    case 'new_transaction':
      return LucideIcons.fileText;
    case 'complaint_reply':
      return LucideIcons.messageCircleReply;
    case 'system':
      return LucideIcons.bell;
    default:
      return LucideIcons.bellRing;
  }
}

Color notificationTypeColor(String type) {
  switch (type.toLowerCase()) {
    case 'transaction_rejected':
      return AppColors.error;
    case 'transaction_approved':
      return AppColors.primary;
    case 'new_transaction':
    case 'complaint_reply':
      return AppColors.goldDark;
    default:
      return AppColors.primary;
  }
}

String formatRelativeNotificationTime(DateTime? date, {DateTime? now}) {
  if (date == null) return '';
  final localDate = date.toLocal();
  final current = now ?? DateTime.now();
  final difference = current.difference(localDate);
  if (difference.isNegative || difference.inMinutes < 1) return 'الآن';
  if (difference.inMinutes < 60) return 'منذ ${difference.inMinutes} دقائق';
  if (difference.inHours < 24) return 'منذ ${difference.inHours} ساعات';
  if (difference.inDays == 1) return 'أمس';
  if (difference.inDays <= 6) return 'منذ ${difference.inDays} أيام';
  return _formatDate(localDate);
}

String formatNotificationDateTime(DateTime? date) {
  if (date == null) return 'التاريخ غير متوفر';
  final local = date.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${_formatDate(local)} • $hour:$minute';
}

String _formatDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day/$month/${value.year}';
}
