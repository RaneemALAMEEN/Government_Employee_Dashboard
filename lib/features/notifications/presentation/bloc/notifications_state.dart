import 'package:equatable/equatable.dart';

import '../../domain/entities/notification_entity.dart';

const _unsetNotificationValue = Object();

class NotificationsState extends Equatable {
  final List<NotificationEntity> items;
  final bool unreadOnly;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool hasNext;
  final String? nextCursor;
  final int unreadCount;
  final String? errorMessage;
  final String? loadMoreError;

  const NotificationsState({
    this.items = const [],
    this.unreadOnly = false,
    this.isInitialLoading = false,
    this.isLoadingMore = false,
    this.hasNext = true,
    this.nextCursor,
    this.unreadCount = 0,
    this.errorMessage,
    this.loadMoreError,
  });

  NotificationsState copyWith({
    List<NotificationEntity>? items,
    bool? unreadOnly,
    bool? isInitialLoading,
    bool? isLoadingMore,
    bool? hasNext,
    Object? nextCursor = _unsetNotificationValue,
    int? unreadCount,
    Object? errorMessage = _unsetNotificationValue,
    Object? loadMoreError = _unsetNotificationValue,
  }) =>
      NotificationsState(
        items: items ?? this.items,
        unreadOnly: unreadOnly ?? this.unreadOnly,
        isInitialLoading: isInitialLoading ?? this.isInitialLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasNext: hasNext ?? this.hasNext,
        nextCursor: identical(nextCursor, _unsetNotificationValue)
            ? this.nextCursor
            : nextCursor as String?,
        unreadCount: unreadCount ?? this.unreadCount,
        errorMessage: identical(errorMessage, _unsetNotificationValue)
            ? this.errorMessage
            : errorMessage as String?,
        loadMoreError: identical(loadMoreError, _unsetNotificationValue)
            ? this.loadMoreError
            : loadMoreError as String?,
      );

  @override
  List<Object?> get props => [
        items,
        unreadOnly,
        isInitialLoading,
        isLoadingMore,
        hasNext,
        nextCursor,
        unreadCount,
        errorMessage,
        loadMoreError,
      ];
}
