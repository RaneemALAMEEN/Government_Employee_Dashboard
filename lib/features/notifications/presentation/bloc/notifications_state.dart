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
  final int? markingReadNotificationId;
  final int? markReadErrorNotificationId;
  final Set<int> openedNotificationIds;
  final bool isBulkMarkingRead;
  final bool isClearingOldUnread;
  final bool isMonitoring;
  final String? syncErrorMessage;
  final List<NotificationEntity> popupItems;
  final Set<int> popupSessionNewIds;
  final bool isPopupLoading;
  final bool isPopupLoadingMore;
  final bool popupHasNext;
  final String? popupNextCursor;
  final String? popupErrorMessage;
  final Set<int> sessionNewNotificationIds;
  final Set<int> pendingVisibleReadIds;
  final Set<int> markingReadIds;
  final bool isPopupOpen;
  final bool isClosingPopupAndMarkingRead;
  final bool isNotificationsPageOpen;
  final DateTime? notificationSessionStartedAt;

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
    this.markingReadNotificationId,
    this.markReadErrorNotificationId,
    this.openedNotificationIds = const {},
    this.isBulkMarkingRead = false,
    this.isClearingOldUnread = false,
    this.isMonitoring = false,
    this.syncErrorMessage,
    this.popupItems = const [],
    this.popupSessionNewIds = const {},
    this.isPopupLoading = false,
    this.isPopupLoadingMore = false,
    this.popupHasNext = false,
    this.popupNextCursor,
    this.popupErrorMessage,
    this.sessionNewNotificationIds = const {},
    this.pendingVisibleReadIds = const {},
    this.markingReadIds = const {},
    this.isPopupOpen = false,
    this.isClosingPopupAndMarkingRead = false,
    this.isNotificationsPageOpen = false,
    this.notificationSessionStartedAt,
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
    Object? markingReadNotificationId = _unsetNotificationValue,
    Object? markReadErrorNotificationId = _unsetNotificationValue,
    Set<int>? openedNotificationIds,
    bool? isBulkMarkingRead,
    bool? isClearingOldUnread,
    bool? isMonitoring,
    Object? syncErrorMessage = _unsetNotificationValue,
    List<NotificationEntity>? popupItems,
    Set<int>? popupSessionNewIds,
    bool? isPopupLoading,
    bool? isPopupLoadingMore,
    bool? popupHasNext,
    Object? popupNextCursor = _unsetNotificationValue,
    Object? popupErrorMessage = _unsetNotificationValue,
    Set<int>? sessionNewNotificationIds,
    Set<int>? pendingVisibleReadIds,
    Set<int>? markingReadIds,
    bool? isPopupOpen,
    bool? isClosingPopupAndMarkingRead,
    bool? isNotificationsPageOpen,
    Object? notificationSessionStartedAt = _unsetNotificationValue,
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
        markingReadNotificationId:
            identical(markingReadNotificationId, _unsetNotificationValue)
                ? this.markingReadNotificationId
                : markingReadNotificationId as int?,
        markReadErrorNotificationId:
            identical(markReadErrorNotificationId, _unsetNotificationValue)
                ? this.markReadErrorNotificationId
                : markReadErrorNotificationId as int?,
        openedNotificationIds:
            openedNotificationIds ?? this.openedNotificationIds,
        isBulkMarkingRead: isBulkMarkingRead ?? this.isBulkMarkingRead,
        isClearingOldUnread: isClearingOldUnread ?? this.isClearingOldUnread,
        isMonitoring: isMonitoring ?? this.isMonitoring,
        syncErrorMessage: identical(syncErrorMessage, _unsetNotificationValue)
            ? this.syncErrorMessage
            : syncErrorMessage as String?,
        popupItems: popupItems ?? this.popupItems,
        popupSessionNewIds: popupSessionNewIds ?? this.popupSessionNewIds,
        isPopupLoading: isPopupLoading ?? this.isPopupLoading,
        isPopupLoadingMore: isPopupLoadingMore ?? this.isPopupLoadingMore,
        popupHasNext: popupHasNext ?? this.popupHasNext,
        popupNextCursor: identical(popupNextCursor, _unsetNotificationValue)
            ? this.popupNextCursor
            : popupNextCursor as String?,
        popupErrorMessage: identical(popupErrorMessage, _unsetNotificationValue)
            ? this.popupErrorMessage
            : popupErrorMessage as String?,
        sessionNewNotificationIds:
            sessionNewNotificationIds ?? this.sessionNewNotificationIds,
        pendingVisibleReadIds:
            pendingVisibleReadIds ?? this.pendingVisibleReadIds,
        markingReadIds: markingReadIds ?? this.markingReadIds,
        isPopupOpen: isPopupOpen ?? this.isPopupOpen,
        isClosingPopupAndMarkingRead:
            isClosingPopupAndMarkingRead ?? this.isClosingPopupAndMarkingRead,
        isNotificationsPageOpen:
            isNotificationsPageOpen ?? this.isNotificationsPageOpen,
        notificationSessionStartedAt:
            identical(notificationSessionStartedAt, _unsetNotificationValue)
                ? this.notificationSessionStartedAt
                : notificationSessionStartedAt as DateTime?,
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
        markingReadNotificationId,
        markReadErrorNotificationId,
        openedNotificationIds,
        isBulkMarkingRead,
        isClearingOldUnread,
        isMonitoring,
        syncErrorMessage,
        popupItems,
        popupSessionNewIds,
        isPopupLoading,
        isPopupLoadingMore,
        popupHasNext,
        popupNextCursor,
        popupErrorMessage,
        sessionNewNotificationIds,
        pendingVisibleReadIds,
        markingReadIds,
        isPopupOpen,
        isClosingPopupAndMarkingRead,
        isNotificationsPageOpen,
        notificationSessionStartedAt,
      ];
}
