import '../../../core/di/injection.dart';
import '../../../core/services/api_service.dart';
import '../data/datasources/notifications_remote_data_source.dart';
import '../data/repositories/notifications_repository_impl.dart';
import '../domain/repositories/notifications_repository.dart';
import '../domain/usecases/get_my_notifications.dart';
import '../presentation/bloc/notifications_bloc.dart';

Future<void> setupNotificationsInjection() async {
  if (!getIt.isRegistered<NotificationsRemoteDataSource>()) {
    getIt.registerLazySingleton(
      () => NotificationsRemoteDataSource(getIt<ApiService>()),
    );
  }
  if (!getIt.isRegistered<NotificationsRepository>()) {
    getIt.registerLazySingleton<NotificationsRepository>(
      () => NotificationsRepositoryImpl(
        getIt<NotificationsRemoteDataSource>(),
      ),
    );
  }
  if (!getIt.isRegistered<GetMyNotifications>()) {
    getIt.registerLazySingleton(
      () => GetMyNotifications(getIt<NotificationsRepository>()),
    );
  }
  if (!getIt.isRegistered<NotificationsBloc>()) {
    getIt.registerFactory(
      () => NotificationsBloc(
        getMyNotifications: getIt<GetMyNotifications>(),
      ),
    );
  }
}
