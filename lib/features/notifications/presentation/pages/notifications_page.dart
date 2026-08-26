import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../domain/entities/notification_entity.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import '../bloc/notifications_state.dart';
import '../widgets/notification_widgets.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ScrollController _scrollController = ScrollController();
  late final NotificationsBloc _notificationsBloc;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    final bloc = _notificationsBloc = context.read<NotificationsBloc>();
    if (kDebugMode) {
      debugPrint(
        '[NotificationsBloc][Page] instance=${identityHashCode(bloc)}',
      );
    }
    bloc.add(const NotificationsPageOpened());
    if (bloc.state.items.isEmpty && !bloc.state.isInitialLoading) {
      bloc.add(LoadNotifications(unreadOnly: bloc.state.unreadOnly));
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 250) {
      context.read<NotificationsBloc>().add(const LoadMoreNotifications());
    }
  }

  @override
  void dispose() {
    _notificationsBloc.add(const NotificationsPageClosed());
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: ColoredBox(
          color: AppColors.background,
          child: BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) => CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(28, 20, 28, 12),
                  sliver: SliverToBoxAdapter(
                    child: _NotificationsHeader(state: state),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 12),
                  sliver: SliverToBoxAdapter(
                    child: _NotificationFilter(
                      unreadOnly: state.unreadOnly,
                      onChanged: (value) => context
                          .read<NotificationsBloc>()
                          .add(ChangeNotificationFilter(unreadOnly: value)),
                    ),
                  ),
                ),
                if (state.isInitialLoading)
                  const SliverPadding(
                    padding: EdgeInsets.fromLTRB(28, 0, 28, 30),
                    sliver: SliverToBoxAdapter(
                      child: SizedBox(
                        height: 580,
                        child: NotificationSkeletonList(),
                      ),
                    ),
                  )
                else if (state.errorMessage != null && state.items.isEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 30),
                    sliver: SliverFillRemaining(
                      hasScrollBody: false,
                      child: NotificationsMessageState(
                        message: 'تعذر تحميل الإشعارات',
                        isError: true,
                        onRetry: () => context
                            .read<NotificationsBloc>()
                            .add(const RetryNotifications()),
                      ),
                    ),
                  )
                else if (state.items.isEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 30),
                    sliver: SliverFillRemaining(
                      hasScrollBody: false,
                      child: NotificationsMessageState(
                        message: state.unreadOnly
                            ? 'لا توجد إشعارات غير مقروءة'
                            : 'لا توجد إشعارات حالياً',
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    sliver: SliverList.separated(
                      itemCount: _groupedItems(state).length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, index) {
                        final entry = _groupedItems(state)[index];
                        if (entry is String) {
                          return _NotificationsSectionHeader(label: entry);
                        }
                        final notification = entry as NotificationEntity;
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: Duration(
                            milliseconds: 220 + ((index > 7 ? 7 : index) * 35),
                          ),
                          curve: Curves.easeOutCubic,
                          builder: (_, value, child) => Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 8 * (1 - value)),
                              child: child,
                            ),
                          ),
                          child: VisibilityDetector(
                            key: ValueKey(
                                'page-notification-${notification.id}'),
                            onVisibilityChanged: (visibility) {
                              if (visibility.visibleFraction >= .6) {
                                context.read<NotificationsBloc>().add(
                                      NotificationBecameVisible(
                                          notification.id),
                                    );
                              }
                            },
                            child: NotificationCard(
                              notification: notification,
                              isOpened: state.openedNotificationIds
                                  .contains(notification.id),
                              isMarkingRead: state.markingReadIds
                                  .contains(notification.id),
                              onTap: () => handleNotificationTap(
                                context,
                                notification,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                if (state.items.isNotEmpty)
                  SliverToBoxAdapter(child: _PaginationFooter(state: state)),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        ),
      );

  List<Object> _groupedItems(NotificationsState state) {
    final fresh = state.items
        .where((item) => state.sessionNewNotificationIds.contains(item.id))
        .toList(growable: false);
    final previous = state.items
        .where((item) => !state.sessionNewNotificationIds.contains(item.id))
        .toList(growable: false);
    return [
      if (fresh.isNotEmpty) 'الإشعارات الجديدة (${fresh.length})',
      ...fresh,
      if (previous.isNotEmpty) 'الإشعارات السابقة',
      ...previous,
    ];
  }
}

class _NotificationsSectionHeader extends StatelessWidget {
  final String label;

  const _NotificationsSectionHeader({required this.label});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            const Expanded(child: Divider(color: AppColors.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(label, style: AppTextStyles.titleSmall),
            ),
            const Expanded(child: Divider(color: AppColors.border)),
          ],
        ),
      );
}

class _NotificationsHeader extends StatelessWidget {
  final NotificationsState state;

  const _NotificationsHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final unread = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Text(
        state.unreadCount == 0
            ? 'لا توجد إشعارات غير مقروءة'
            : '${state.unreadCount} غير مقروء',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.forest,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    return AppPageHeader(
      title: 'الإشعارات',
      subtitle: 'متابعة آخر التحديثات والتنبيهات الخاصة بحسابك',
      backButton: AppBackButton(
        label: 'العودة',
        onPressed: context.canPop() ? () => context.pop() : null,
      ),
      trailing: unread,
    );
  }
}

class _NotificationFilter extends StatelessWidget {
  final bool unreadOnly;
  final ValueChanged<bool> onChanged;

  const _NotificationFilter({
    required this.unreadOnly,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: AppColors.border.withValues(alpha: .28)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _FilterButton(
                label: 'الكل',
                selected: !unreadOnly,
                onTap: () => onChanged(false),
              ),
              _FilterButton(
                label: 'غير المقروءة',
                selected: unreadOnly,
                onTap: () => onChanged(true),
              ),
            ],
          ),
        ),
      );
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: selected ? AppColors.surface : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
}

class _PaginationFooter extends StatelessWidget {
  final NotificationsState state;

  const _PaginationFooter({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: SizedBox(
            width: 23,
            height: 23,
            child: CircularProgressIndicator(strokeWidth: 2.3),
          ),
        ),
      );
    }
    if (state.loadMoreError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('تعذر تحميل المزيد'),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () => context
                  .read<NotificationsBloc>()
                  .add(const RetryLoadMoreNotifications()),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }
    return const SizedBox(height: 14);
  }
}
