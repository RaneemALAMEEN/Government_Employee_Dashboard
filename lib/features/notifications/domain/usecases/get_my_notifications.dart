import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/notifications_response_entity.dart';
import '../repositories/notifications_repository.dart';

class GetMyNotifications {
  final NotificationsRepository repository;

  const GetMyNotifications(this.repository);

  Future<Either<Failure, NotificationsResponseEntity>> call({
    required int limit,
    String? cursor,
    bool unreadOnly = false,
  }) =>
      repository.getMyNotifications(
        limit: limit,
        cursor: cursor,
        unreadOnly: unreadOnly,
      );
}
