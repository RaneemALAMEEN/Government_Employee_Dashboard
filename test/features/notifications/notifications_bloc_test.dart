import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:government_employee_dashboard/core/errors/failures.dart';
import 'package:government_employee_dashboard/features/notifications/domain/entities/notification_entity.dart';
import 'package:government_employee_dashboard/features/notifications/domain/entities/notifications_pagination_entity.dart';
import 'package:government_employee_dashboard/features/notifications/domain/entities/notifications_response_entity.dart';
import 'package:government_employee_dashboard/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:government_employee_dashboard/features/notifications/domain/usecases/get_my_notifications.dart';
import 'package:government_employee_dashboard/features/notifications/domain/usecases/mark_notification_as_read.dart'
    as usecase;
import 'package:government_employee_dashboard/features/notifications/domain/usecases/mark_notifications_as_read.dart';
import 'package:government_employee_dashboard/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:government_employee_dashboard/features/notifications/presentation/bloc/notifications_event.dart';

void main() {
  test('marks the tapped notification and decrements unread count', () async {
    final repository = _FakeNotificationsRepository();
    final bloc = NotificationsBloc(
      getMyNotifications: GetMyNotifications(repository),
      markNotificationAsRead: usecase.MarkNotificationAsRead(repository),
      markNotificationsAsRead: MarkNotificationsAsRead(repository),
    );
    addTearDown(bloc.close);

    bloc.add(const LoadNotifications());
    await bloc.stream.firstWhere(
      (state) => !state.isInitialLoading && state.items.isNotEmpty,
    );

    bloc.add(const MarkNotificationAsRead(notificationId: 7));
    final updated = await bloc.stream.firstWhere(
      (state) => state.items.first.isRead,
    );

    expect(repository.markedNotificationId, 7);
    expect(updated.items.first.isRead, isTrue);
    expect(updated.items.first.readAt, isNotNull);
    expect(updated.unreadCount, 0);
  });

  test('popup keeps new items unread until close, then marks them in one batch',
      () async {
    final repository = _PersistingNotificationsRepository();
    final bloc = NotificationsBloc(
      getMyNotifications: GetMyNotifications(repository),
      markNotificationAsRead: usecase.MarkNotificationAsRead(repository),
      markNotificationsAsRead: MarkNotificationsAsRead(repository),
    );
    addTearDown(bloc.close);

    bloc.add(const NotificationsPopupOpened());
    await bloc.stream.firstWhere(
      (state) => !state.isPopupLoading && state.popupItems.length == 2,
    );

    expect(repository.bulkMarkCalls, isEmpty);
    expect(bloc.state.sessionNewNotificationIds, {1, 2});
    expect(bloc.state.popupSessionNewIds, {1, 2});

    bloc
      ..add(const NotificationBecameVisible(1))
      ..add(const NotificationBecameVisible(2));
    await Future<void>.delayed(const Duration(milliseconds: 500));

    expect(repository.bulkMarkCalls, isEmpty);
    expect(bloc.state.unreadCount, 4353);
    expect(bloc.state.popupSessionNewIds, {1, 2});
    expect(bloc.state.popupItems.every((item) => !item.isRead), isTrue);

    bloc.add(const NotificationsPopupClosed());
    final updated = await bloc.stream.firstWhere(
      (state) =>
          !state.isPopupOpen &&
          !state.isClosingPopupAndMarkingRead &&
          state.unreadCount == 4351,
    );

    expect(repository.bulkMarkCalls.single, unorderedEquals([1, 2]));
    expect(updated.popupSessionNewIds, isEmpty);
    expect(updated.popupItems, isEmpty);
    expect(updated.unreadCount, 4351);
  });

  test('moving from popup to page preserves the notification session snapshot',
      () async {
    final repository = _PersistingNotificationsRepository();
    final bloc = NotificationsBloc(
      getMyNotifications: GetMyNotifications(repository),
      markNotificationAsRead: usecase.MarkNotificationAsRead(repository),
      markNotificationsAsRead: MarkNotificationsAsRead(repository),
    );
    addTearDown(bloc.close);

    bloc.add(const NotificationsPopupOpened());
    await bloc.stream.firstWhere(
      (state) => !state.isPopupLoading && state.popupItems.isNotEmpty,
    );
    bloc.add(const NotificationsPopupClosed(preserveSession: true));
    await bloc.stream.firstWhere(
      (state) => !state.isPopupOpen && !state.isClosingPopupAndMarkingRead,
    );
    bloc.add(const NotificationsPageOpened());
    await bloc.stream.firstWhere((state) => state.isNotificationsPageOpen);

    expect(bloc.state.sessionNewNotificationIds, {1, 2});
    expect(bloc.state.popupItems, isEmpty);
    expect(bloc.state.popupSessionNewIds, isEmpty);
    expect(bloc.state.notificationSessionStartedAt, isNotNull);
  });

  test('refreshes unread count with limit 1 and prepends latest item once',
      () async {
    final repository = _MonitoringNotificationsRepository();
    final bloc = NotificationsBloc(
      getMyNotifications: GetMyNotifications(repository),
      markNotificationAsRead: usecase.MarkNotificationAsRead(repository),
      markNotificationsAsRead: MarkNotificationsAsRead(repository),
    );
    addTearDown(bloc.close);

    bloc.add(const LoadNotifications());
    await bloc.stream.firstWhere((state) => state.items.isNotEmpty);
    bloc.add(const StartNotificationsMonitoring());
    await Future<void>.delayed(Duration.zero);

    repository
      ..unreadCount = 1
      ..latestId = 9;
    bloc.add(const RefreshUnreadCount(syncLatestNotification: true));
    final updated = await bloc.stream.firstWhere(
      (state) => state.unreadCount == 1 && state.items.first.id == 9,
    );
    bloc.add(const RefreshUnreadCount(syncLatestNotification: true));
    await Future<void>.delayed(Duration.zero);

    expect(repository.requestedLimits.last, 1);
    expect(updated.items.where((item) => item.id == 9), hasLength(1));
    expect(bloc.state.items.where((item) => item.id == 9), hasLength(1));
  });

  test('notification received increments count only once per id', () async {
    final repository = _FakeNotificationsRepository();
    final bloc = NotificationsBloc(
      getMyNotifications: GetMyNotifications(repository),
      markNotificationAsRead: usecase.MarkNotificationAsRead(repository),
      markNotificationsAsRead: MarkNotificationsAsRead(repository),
    );
    addTearDown(bloc.close);
    const notification = NotificationEntity(
      id: 8,
      title: 'New',
      message: 'New',
      type: 'system',
      isRead: false,
      createdAt: null,
    );

    bloc.add(const LoadNotifications());
    await bloc.stream.firstWhere((state) => state.items.isNotEmpty);
    bloc.add(const NotificationReceived(notification: notification));
    await bloc.stream.firstWhere((state) => state.items.length == 2);
    bloc.add(const NotificationReceived(notification: notification));
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.items.first, notification);
    expect(bloc.state.items.where((item) => item.id == 8), hasLength(1));
    expect(bloc.state.unreadCount, 2);
  });
}

class _FakeNotificationsRepository implements NotificationsRepository {
  int? markedNotificationId;
  final Set<int> _readIds = {};

  @override
  Future<Either<Failure, NotificationsResponseEntity>> getMyNotifications({
    required int limit,
    String? cursor,
    bool unreadOnly = false,
  }) async =>
      Right(
        NotificationsResponseEntity(
          items: [
            NotificationEntity(
              id: 7,
              title: 'إشعار',
              message: 'رسالة',
              type: 'system',
              isRead: _readIds.contains(7),
              createdAt: null,
            ),
          ],
          pagination: const NotificationsPaginationEntity(
            limit: 10,
            cursor: null,
            nextCursor: null,
            hasNext: false,
            hasPrev: false,
          ),
          unreadCount: _readIds.contains(7) ? 0 : 1,
        ),
      );

  @override
  Future<Either<Failure, Unit>> markNotificationAsRead(
    int notificationId,
  ) async {
    markedNotificationId = notificationId;
    _readIds.add(notificationId);
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> markNotificationsAsRead(
    List<int> notificationIds,
  ) async {
    markedNotificationId =
        notificationIds.isEmpty ? null : notificationIds.first;
    _readIds.addAll(notificationIds);
    return const Right(unit);
  }
}

class _MonitoringNotificationsRepository implements NotificationsRepository {
  final List<int> requestedLimits = [];
  int unreadCount = 0;
  int latestId = 1;

  @override
  Future<Either<Failure, NotificationsResponseEntity>> getMyNotifications({
    required int limit,
    String? cursor,
    bool unreadOnly = false,
  }) async {
    requestedLimits.add(limit);
    return Right(
      NotificationsResponseEntity(
        items: [
          NotificationEntity(
            id: latestId,
            title: 'Notification $latestId',
            message: 'Message',
            type: 'system',
            isRead: unreadCount == 0,
            createdAt: null,
          ),
        ],
        pagination: NotificationsPaginationEntity(
          limit: limit,
          cursor: null,
          nextCursor: null,
          hasNext: false,
          hasPrev: false,
        ),
        unreadCount: unreadCount,
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> markNotificationAsRead(
    int notificationId,
  ) async =>
      const Right(unit);

  @override
  Future<Either<Failure, Unit>> markNotificationsAsRead(
    List<int> notificationIds,
  ) async =>
      const Right(unit);
}

class _PersistingNotificationsRepository implements NotificationsRepository {
  static const int serverUnreadCount = 4353;
  final List<List<int>> bulkMarkCalls = [];
  final List<int> markCalls = [];
  final Set<int> _readIds = {};
  int getCalls = 0;

  @override
  Future<Either<Failure, NotificationsResponseEntity>> getMyNotifications({
    required int limit,
    String? cursor,
    bool unreadOnly = false,
  }) async {
    getCalls++;
    final items = [1, 2]
        .map(
          (id) => NotificationEntity(
            id: id,
            title: 'Notification $id',
            message: 'Message',
            type: 'system',
            isRead: _readIds.contains(id),
            createdAt: null,
          ),
        )
        .where((item) => !unreadOnly || !item.isRead)
        .toList(growable: false);
    return Right(
      NotificationsResponseEntity(
        items: items,
        pagination: NotificationsPaginationEntity(
          limit: limit,
          cursor: null,
          nextCursor: null,
          hasNext: false,
          hasPrev: false,
        ),
        unreadCount: serverUnreadCount - _readIds.length,
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> markNotificationAsRead(
    int notificationId,
  ) async {
    markCalls.add(notificationId);
    _readIds.add(notificationId);
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> markNotificationsAsRead(
    List<int> notificationIds,
  ) async {
    bulkMarkCalls.add(notificationIds);
    _readIds.addAll(notificationIds);
    return const Right(unit);
  }
}
