import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/notifications_repository.dart';

class MarkNotificationAsRead {
  final NotificationsRepository repository;

  const MarkNotificationAsRead(this.repository);

  Future<Either<Failure, Unit>> call(int notificationId) =>
      repository.markNotificationAsRead(notificationId);
}
