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
import 'package:government_employee_dashboard/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:government_employee_dashboard/features/notifications/presentation/bloc/notifications_event.dart';

void main() {
  test('marks the tapped notification and decrements unread count', () async {
    final repository = _FakeNotificationsRepository();
    final bloc = NotificationsBloc(
      getMyNotifications: GetMyNotifications(repository),
      markNotificationAsRead: usecase.MarkNotificationAsRead(repository),
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
}

class _FakeNotificationsRepository implements NotificationsRepository {
  int? markedNotificationId;

  @override
  Future<Either<Failure, NotificationsResponseEntity>> getMyNotifications({
    required int limit,
    String? cursor,
    bool unreadOnly = false,
  }) async =>
      const Right(
        NotificationsResponseEntity(
          items: [
            NotificationEntity(
              id: 7,
              title: 'إشعار',
              message: 'رسالة',
              type: 'system',
              isRead: false,
              createdAt: null,
            ),
          ],
          pagination: NotificationsPaginationEntity(
            limit: 10,
            cursor: null,
            nextCursor: null,
            hasNext: false,
            hasPrev: false,
          ),
          unreadCount: 1,
        ),
      );

  @override
  Future<Either<Failure, Unit>> markNotificationAsRead(
    int notificationId,
  ) async {
    markedNotificationId = notificationId;
    return const Right(unit);
  }
}
