import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/get_my_notifications.dart';
import '../../domain/usecases/mark_notification_as_read.dart' as usecase;
import '../../domain/usecases/mark_notifications_as_read.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  static const int limit = 10;
  static const int popupLimit = 20;

  final GetMyNotifications getMyNotifications;
  final usecase.MarkNotificationAsRead markNotificationAsRead;
  final MarkNotificationsAsRead markNotificationsAsRead;

  final Set<String> _requestedCursors = <String>{};
  final Set<int> _markingReadIds = <int>{};
  final Set<int> _alreadyMarkedThisSessionIds = <int>{};
  Timer? _visibleReadDebounce;
  bool _isMonitoring = false;
  bool _isRefreshingUnreadCount = false;
  int _generation = 0;
  int _popupGeneration = 0;

  NotificationsBloc({
    required this.getMyNotifications,
    required this.markNotificationAsRead,
    required this.markNotificationsAsRead,
  }) : super(const NotificationsState()) {
    on<LoadNotifications>(_loadInitial);
    on<LoadMoreNotifications>(_loadMore);
    on<ChangeNotificationFilter>(_changeFilter);
    on<RetryLoadMoreNotifications>(_retryMore);
    on<RetryNotifications>(_retryInitial);
    on<NotificationsPopupOpened>(_popupOpened);
    on<NotificationsPopupClosed>(_popupClosed);
    on<NotificationsPageOpened>(_pageOpened);
    on<NotificationsPageClosed>(_pageClosed);
    on<LoadMorePopupNotifications>(_loadMorePopup);
    on<NotificationBecameVisible>(_becameVisible);
    on<FlushVisibleNotificationsRead>(_flushVisibleReads);
    on<StartNotificationsMonitoring>(_startMonitoring);
    on<StopNotificationsMonitoring>(_stopMonitoring);
    on<RefreshUnreadCount>(_refreshUnreadCount);
    on<NotificationReceived>(_notificationReceived);
    on<MarkNotificationAsRead>(_markAsRead);
    on<NotificationOpened>(_notificationOpened);

    if (kDebugMode) {
      debugPrint('[NotificationsBloc] instance=${identityHashCode(this)}');
    }
  }

  Future<void> _loadInitial(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state.isInitialLoading ||
        (state.items.isNotEmpty && state.unreadOnly == event.unreadOnly)) {
      return;
    }
    if (state.unreadOnly != event.unreadOnly) {
      _generation++;
      _requestedCursors.clear();
    }
    final generation = _generation;
    final requestKey = '${event.unreadOnly}:initial';
    if (!_requestedCursors.add(requestKey)) return;
    emit(state.copyWith(
      items: const [],
      unreadOnly: event.unreadOnly,
      isInitialLoading: true,
      hasNext: true,
      nextCursor: null,
      errorMessage: null,
    ));

    final result = await getMyNotifications(
      limit: limit,
      unreadOnly: event.unreadOnly,
    );
    if (generation != _generation) return;
    result.fold(
      (failure) {
        _requestedCursors.remove(requestKey);
        emit(state.copyWith(
          isInitialLoading: false,
          errorMessage: failure.message,
        ));
      },
      (response) {
        final pagination = response.pagination;
        emit(state.copyWith(
          items: response.items,
          popupItems: state.isPopupOpen &&
                  !state.isPopupLoading &&
                  state.popupItems.isEmpty
              ? response.items.take(5).toList(growable: false)
              : state.popupItems,
          isInitialLoading: false,
          hasNext: pagination.hasNext && pagination.nextCursor != null,
          nextCursor: pagination.nextCursor,
          unreadCount: response.unreadCount,
          errorMessage: null,
          sessionNewNotificationIds: _sessionIdsWith(response.items),
        ));
      },
    );
  }

  Future<void> _loadMore(
    LoadMoreNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasNext) return;
    final cursor = state.nextCursor;
    if (cursor == null || cursor.isEmpty) return;
    final requestKey = '${state.unreadOnly}:$cursor';
    if (!_requestedCursors.add(requestKey)) return;
    final generation = _generation;
    emit(state.copyWith(isLoadingMore: true, loadMoreError: null));
    final result = await getMyNotifications(
      limit: limit,
      cursor: cursor,
      unreadOnly: state.unreadOnly,
    );
    if (generation != _generation) return;
    result.fold(
      (failure) {
        _requestedCursors.remove(requestKey);
        emit(state.copyWith(
          isLoadingMore: false,
          loadMoreError: failure.message,
        ));
      },
      (response) => emit(state.copyWith(
        items: _mergeById(state.items, response.items),
        isLoadingMore: false,
        hasNext: response.pagination.hasNext &&
            response.pagination.nextCursor != null,
        nextCursor: response.pagination.nextCursor,
        unreadCount: response.unreadCount,
        loadMoreError: null,
        sessionNewNotificationIds: _sessionIdsWith(response.items),
      )),
    );
  }

  Future<void> _popupOpened(
    NotificationsPopupOpened event,
    Emitter<NotificationsState> emit,
  ) async {
    final popupGeneration = ++_popupGeneration;
    final startsSession = !state.isPopupOpen && !state.isNotificationsPageOpen;
    if (startsSession) {
      _alreadyMarkedThisSessionIds.clear();
      emit(state.copyWith(
        sessionNewNotificationIds: const {},
        pendingVisibleReadIds: const {},
        notificationSessionStartedAt: DateTime.now(),
      ));
    }
    emit(state.copyWith(
      isPopupOpen: true,
      isPopupLoading: true,
      popupItems: const [],
      popupSessionNewIds: const {},
      popupHasNext: false,
      popupNextCursor: null,
      popupErrorMessage: null,
    ));
    final result = await getMyNotifications(
      limit: popupLimit,
      unreadOnly: true,
    );
    if (popupGeneration != _popupGeneration || !state.isPopupOpen) return;
    result.fold(
      (failure) => emit(state.copyWith(
        isPopupLoading: false,
        popupErrorMessage: failure.message,
      )),
      (response) {
        final unreadItems = response.items
            .where((item) => !item.isRead)
            .toList(growable: false);
        final preview = unreadItems.isEmpty
            ? state.items.take(5).toList(growable: false)
            : unreadItems;
        final popupNewIds = unreadItems.map((item) => item.id).toSet();
        emit(state.copyWith(
          popupItems: preview,
          popupSessionNewIds: popupNewIds,
          isPopupLoading: false,
          popupHasNext: response.pagination.hasNext &&
              response.pagination.nextCursor != null,
          popupNextCursor: response.pagination.nextCursor,
          unreadCount: response.unreadCount,
          sessionNewNotificationIds: _sessionIdsWith(response.items),
        ));
      },
    );
  }

  Future<void> _popupClosed(
    NotificationsPopupClosed event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state.isClosingPopupAndMarkingRead || !state.isPopupOpen) return;
    final ids = state.popupSessionNewIds
        .where((id) => !_markingReadIds.contains(id))
        .toSet();
    emit(state.copyWith(isClosingPopupAndMarkingRead: true));

    if (ids.isNotEmpty) {
      _markingReadIds.addAll(ids);
      final result = await markNotificationsAsRead(ids.toList(growable: false));
      _markingReadIds.removeAll(ids);
      result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint(
              '[Notifications] failed to mark popup session as read: '
              '${failure.message}',
            );
          }
        },
        (_) {
          _alreadyMarkedThisSessionIds.addAll(ids);
          final now = DateTime.now();
          NotificationEntity mark(NotificationEntity item) =>
              ids.contains(item.id)
                  ? item.copyWith(isRead: true, readAt: now)
                  : item;
          emit(state.copyWith(
            items: state.items.map(mark).toList(growable: false),
            popupItems: state.popupItems.map(mark).toList(growable: false),
            unreadCount:
                (state.unreadCount - ids.length).clamp(0, state.unreadCount),
          ));
        },
      );
    }

    _popupGeneration++;
    emit(state.copyWith(
      isPopupOpen: false,
      isClosingPopupAndMarkingRead: false,
      popupItems: const [],
      popupSessionNewIds: const {},
      isPopupLoading: false,
      isPopupLoadingMore: false,
      popupHasNext: false,
      popupNextCursor: null,
      popupErrorMessage: null,
    ));
    if (!event.preserveSession && !state.isNotificationsPageOpen) {
      _endSession(emit);
    }
  }

  void _pageOpened(
    NotificationsPageOpened event,
    Emitter<NotificationsState> emit,
  ) {
    final startsSession = state.notificationSessionStartedAt == null;
    emit(state.copyWith(
      isNotificationsPageOpen: true,
      notificationSessionStartedAt:
          startsSession ? DateTime.now() : state.notificationSessionStartedAt,
      sessionNewNotificationIds: startsSession
          ? state.items
              .where((item) => !item.isRead)
              .map((item) => item.id)
              .toSet()
          : state.sessionNewNotificationIds,
    ));
  }

  void _pageClosed(
    NotificationsPageClosed event,
    Emitter<NotificationsState> emit,
  ) {
    emit(state.copyWith(isNotificationsPageOpen: false));
    if (!state.isPopupOpen) {
      _endSession(emit);
    }
  }

  void _endSession(Emitter<NotificationsState> emit) {
    _visibleReadDebounce?.cancel();
    _alreadyMarkedThisSessionIds.clear();
    emit(state.copyWith(
      sessionNewNotificationIds: const {},
      pendingVisibleReadIds: const {},
      markingReadIds: const {},
      notificationSessionStartedAt: null,
    ));
  }

  Future<void> _loadMorePopup(
    LoadMorePopupNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state.isPopupLoadingMore || !state.popupHasNext) return;
    final popupGeneration = _popupGeneration;
    final cursor = state.popupNextCursor;
    if (cursor == null) return;
    emit(state.copyWith(isPopupLoadingMore: true, popupErrorMessage: null));
    final result = await getMyNotifications(
      limit: popupLimit,
      cursor: cursor,
      unreadOnly: true,
    );
    if (popupGeneration != _popupGeneration || !state.isPopupOpen) return;
    result.fold(
      (failure) => emit(state.copyWith(
        isPopupLoadingMore: false,
        popupErrorMessage: failure.message,
      )),
      (response) => emit(state.copyWith(
        popupItems: _mergeById(state.popupItems, response.items),
        popupSessionNewIds: {
          ...state.popupSessionNewIds,
          ...response.items
              .where((item) => !item.isRead)
              .map((item) => item.id),
        },
        isPopupLoadingMore: false,
        popupHasNext: response.pagination.hasNext &&
            response.pagination.nextCursor != null,
        popupNextCursor: response.pagination.nextCursor,
        unreadCount: response.unreadCount,
        sessionNewNotificationIds: _sessionIdsWith(response.items),
      )),
    );
  }

  void _becameVisible(
    NotificationBecameVisible event,
    Emitter<NotificationsState> emit,
  ) {
    if (state.isPopupOpen) return;
    final candidates = [...state.popupItems, ...state.items];
    final index =
        candidates.indexWhere((item) => item.id == event.notificationId);
    if (index < 0) return;
    final item = candidates[index];
    if (item.isRead ||
        _markingReadIds.contains(item.id) ||
        _alreadyMarkedThisSessionIds.contains(item.id)) {
      return;
    }
    emit(state.copyWith(
      pendingVisibleReadIds: {...state.pendingVisibleReadIds, item.id},
    ));
    _visibleReadDebounce?.cancel();
    _visibleReadDebounce = Timer(
      const Duration(milliseconds: 400),
      () => add(const FlushVisibleNotificationsRead()),
    );
  }

  Future<void> _flushVisibleReads(
    FlushVisibleNotificationsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    final ids = state.pendingVisibleReadIds
        .where((id) =>
            !_markingReadIds.contains(id) &&
            !_alreadyMarkedThisSessionIds.contains(id))
        .toSet();
    if (ids.isEmpty) return;
    _markingReadIds.addAll(ids);
    emit(state.copyWith(
      pendingVisibleReadIds: state.pendingVisibleReadIds.difference(ids),
      markingReadIds: {...state.markingReadIds, ...ids},
      syncErrorMessage: null,
    ));
    final result = await markNotificationsAsRead(ids.toList(growable: false));
    _markingReadIds.removeAll(ids);
    result.fold(
      (failure) => emit(state.copyWith(
        pendingVisibleReadIds: {...state.pendingVisibleReadIds, ...ids},
        markingReadIds: state.markingReadIds.difference(ids),
        syncErrorMessage: 'تعذر تحديث حالة بعض الإشعارات',
      )),
      (_) {
        _alreadyMarkedThisSessionIds.addAll(ids);
        final now = DateTime.now();
        NotificationEntity mark(NotificationEntity item) =>
            ids.contains(item.id)
                ? item.copyWith(isRead: true, readAt: now)
                : item;
        emit(state.copyWith(
          items: state.items.map(mark).toList(growable: false),
          popupItems: state.popupItems.map(mark).toList(growable: false),
          unreadCount:
              (state.unreadCount - ids.length).clamp(0, state.unreadCount),
          markingReadIds: state.markingReadIds.difference(ids),
        ));
      },
    );
  }

  Set<int> _sessionIdsWith(List<NotificationEntity> loaded) {
    if (state.notificationSessionStartedAt == null) {
      return state.sessionNewNotificationIds;
    }
    return {
      ...state.sessionNewNotificationIds,
      ...loaded.where((item) => !item.isRead).map((item) => item.id),
    };
  }

  List<NotificationEntity> _mergeById(
    List<NotificationEntity> current,
    List<NotificationEntity> additions,
  ) {
    final ids = current.map((item) => item.id).toSet();
    return [...current, ...additions.where((item) => ids.add(item.id))];
  }

  void _changeFilter(
    ChangeNotificationFilter event,
    Emitter<NotificationsState> emit,
  ) {
    if (state.unreadOnly == event.unreadOnly) return;
    _generation++;
    _requestedCursors.clear();
    emit(state.copyWith(
      items: const [],
      unreadOnly: event.unreadOnly,
      hasNext: true,
      nextCursor: null,
      errorMessage: null,
    ));
    add(LoadNotifications(unreadOnly: event.unreadOnly));
  }

  void _retryMore(
    RetryLoadMoreNotifications event,
    Emitter<NotificationsState> emit,
  ) {
    add(const LoadMoreNotifications());
  }

  void _retryInitial(
    RetryNotifications event,
    Emitter<NotificationsState> emit,
  ) {
    if (state.isPopupOpen && state.popupItems.isEmpty) {
      add(const NotificationsPopupOpened());
    } else if (state.items.isEmpty) {
      _requestedCursors.remove('${state.unreadOnly}:initial');
      add(LoadNotifications(unreadOnly: state.unreadOnly));
    }
  }

  void _startMonitoring(
    StartNotificationsMonitoring event,
    Emitter<NotificationsState> emit,
  ) {
    if (_isMonitoring) return;
    _isMonitoring = true;
    emit(state.copyWith(isMonitoring: true));
    add(const RefreshUnreadCount());
  }

  void _stopMonitoring(
    StopNotificationsMonitoring event,
    Emitter<NotificationsState> emit,
  ) {
    _isMonitoring = false;
    emit(state.copyWith(isMonitoring: false));
  }

  Future<void> _refreshUnreadCount(
    RefreshUnreadCount event,
    Emitter<NotificationsState> emit,
  ) async {
    if (!_isMonitoring || _isRefreshingUnreadCount) return;
    _isRefreshingUnreadCount = true;
    try {
      final result = await getMyNotifications(limit: 1);
      result.fold(
        (_) {},
        (response) {
          var updatedItems = state.items;
          var updatedPopupItems = state.popupItems;
          var sessionIds = state.sessionNewNotificationIds;
          if (event.syncLatestNotification && response.items.isNotEmpty) {
            final latest = response.items.first;
            if (!state.items.any((item) => item.id == latest.id)) {
              updatedItems = [latest, ...state.items];
            }
            if (state.isPopupOpen &&
                !state.popupItems.any((item) => item.id == latest.id)) {
              updatedPopupItems = [latest, ...state.popupItems];
            }
            if (state.notificationSessionStartedAt != null && !latest.isRead) {
              sessionIds = {...sessionIds, latest.id};
            }
          }
          emit(state.copyWith(
            items: updatedItems,
            popupItems: updatedPopupItems,
            unreadCount: response.unreadCount,
            sessionNewNotificationIds: sessionIds,
          ));
        },
      );
    } finally {
      _isRefreshingUnreadCount = false;
    }
  }

  void _notificationReceived(
    NotificationReceived event,
    Emitter<NotificationsState> emit,
  ) {
    if (state.items.any((item) => item.id == event.notification.id)) return;
    final addToSession = state.notificationSessionStartedAt != null &&
        !event.notification.isRead;
    emit(state.copyWith(
      items: [event.notification, ...state.items],
      popupItems: state.isPopupOpen
          ? [event.notification, ...state.popupItems]
          : state.popupItems,
      popupSessionNewIds: state.isPopupOpen && !event.notification.isRead
          ? {...state.popupSessionNewIds, event.notification.id}
          : state.popupSessionNewIds,
      unreadCount:
          event.notification.isRead ? state.unreadCount : state.unreadCount + 1,
      sessionNewNotificationIds: addToSession
          ? {...state.sessionNewNotificationIds, event.notification.id}
          : state.sessionNewNotificationIds,
    ));
  }

  Future<void> _markAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    final candidates = [...state.items, ...state.popupItems];
    final index =
        candidates.indexWhere((item) => item.id == event.notificationId);
    if (index < 0 ||
        candidates[index].isRead ||
        _markingReadIds.contains(event.notificationId)) {
      return;
    }
    emit(state.copyWith(
      markingReadNotificationId: event.notificationId,
      markReadErrorNotificationId: null,
    ));
    _markingReadIds.add(event.notificationId);
    final result = await markNotificationAsRead(event.notificationId);
    _markingReadIds.remove(event.notificationId);
    result.fold(
      (_) => emit(state.copyWith(
        markingReadNotificationId: null,
        markReadErrorNotificationId: event.notificationId,
      )),
      (_) {
        _alreadyMarkedThisSessionIds.add(event.notificationId);
        final now = DateTime.now();
        NotificationEntity mark(NotificationEntity item) =>
            item.id == event.notificationId
                ? item.copyWith(isRead: true, readAt: now)
                : item;
        emit(state.copyWith(
          items: state.items.map(mark).toList(growable: false),
          popupItems: state.popupItems.map(mark).toList(growable: false),
          unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
          markingReadNotificationId: null,
          markReadErrorNotificationId: null,
        ));
      },
    );
  }

  void _notificationOpened(
    NotificationOpened event,
    Emitter<NotificationsState> emit,
  ) {
    emit(state.copyWith(
      openedNotificationIds: {
        ...state.openedNotificationIds,
        event.notificationId,
      },
    ));
  }

  @override
  Future<void> close() {
    _visibleReadDebounce?.cancel();
    return super.close();
  }
}
