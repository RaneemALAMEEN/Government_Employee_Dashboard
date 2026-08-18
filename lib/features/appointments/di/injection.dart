import 'package:get_it/get_it.dart';

import '../../../core/services/api_service.dart';
import '../data/datasources/appointments_remote_data_source.dart';
import '../data/repositories/appointments_repository_impl.dart';
import '../domain/repositories/appointments_repository.dart';
import '../domain/usecases/appointments_usecases.dart';
import '../presentation/bloc/appointments_bloc.dart';

void setupAppointmentsInjection(GetIt getIt) {
  if (!getIt.isRegistered<AppointmentsRemoteDataSource>()) {
    getIt.registerLazySingleton(
        () => AppointmentsRemoteDataSource(getIt<ApiService>()));
  }
  if (!getIt.isRegistered<AppointmentsRepository>()) {
    getIt.registerLazySingleton<AppointmentsRepository>(
        () => AppointmentsRepositoryImpl(getIt()));
  }
  if (!getIt.isRegistered<AppointmentsUseCases>()) {
    getIt.registerLazySingleton(() => AppointmentsUseCases(getIt()));
  }
  if (!getIt.isRegistered<AppointmentsBloc>()) {
    getIt.registerFactory(() => AppointmentsBloc(getIt()));
  }
}
