import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    final bloc = context.read<NotificationsBloc>();
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
                  padding: const EdgeInsets.fromLTRB(28, 26, 28, 16),
                  sliver: SliverToBoxAdapter(
                    child: _NotificationsHeader(state: state),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 14),
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
                      itemCount: state.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, index) {
                        final notification = state.items[index];
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
                          child: NotificationCard(
                            notification: notification,
                            isMarkingRead: state.markingReadNotificationId ==
                                notification.id,
                            onTap: () => handleNotificationTap(
                              context,
                              notification,
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
}

class _NotificationsHeader extends StatelessWidget {
  final NotificationsState state;

  const _NotificationsHeader({required this.state});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withValues(alpha: .32)),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: .035),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (_, constraints) {
            final compact = constraints.maxWidth < 650;
            final title = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.lightPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.bellRing,
                    color: AppColors.primary,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الإشعارات',
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'متابعة آخر التحديثات والتنبيهات الخاصة بحسابك',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
            final unread = Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.lightPrimary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                state.unreadCount == 0
                    ? 'لا توجد إشعارات غير مقروءة'
                    : 'لديك ${state.unreadCount} إشعارات غير مقروءة',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [title, const SizedBox(height: 13), unread],
              );
            }
            return Row(
              children: [
                Expanded(child: title),
                const SizedBox(width: 18),
                unread,
              ],
            );
          },
        ),
      );
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
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
