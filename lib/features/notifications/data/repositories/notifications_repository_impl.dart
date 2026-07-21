import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/notifications_response_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_data_source.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource remoteDataSource;

  const NotificationsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, NotificationsResponseEntity>> getMyNotifications({
    required int limit,
    String? cursor,
    bool unreadOnly = false,
  }) async {
    try {
      return Right(await remoteDataSource.getMyNotifications(
        limit: limit,
        cursor: cursor,
        unreadOnly: unreadOnly,
      ));
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> markNotificationAsRead(
    int notificationId,
  ) async {
    try {
      await remoteDataSource.markNotificationAsRead(notificationId);
      return const Right(unit);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }
}
