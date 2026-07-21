import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/notifications_response_entity.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, NotificationsResponseEntity>> getMyNotifications({
    required int limit,
    String? cursor,
    bool unreadOnly = false,
  });

  Future<Either<Failure, Unit>> markNotificationAsRead(int notificationId);
}
