import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/notifications_repository.dart';

class MarkNotificationsAsRead {
  final NotificationsRepository repository;

  const MarkNotificationsAsRead(this.repository);

  Future<Either<Failure, Unit>> call(List<int> notificationIds) =>
      repository.markNotificationsAsRead(notificationIds);
}
