import '../../../core/di/injection.dart';
import '../../../core/services/api_service.dart';
import '../data/datasources/directorate_process_remote_data_source.dart';
import '../data/repositories/directorate_process_repository_impl.dart';
import '../domain/repositories/directorate_process_repository.dart';
import '../domain/usecases/get_process_definitions.dart';
import '../domain/usecases/get_process_details.dart';
import '../domain/usecases/get_complaint_process_definitions.dart';
import '../domain/usecases/get_transaction_types.dart';
import '../presentation/bloc/directorate_process_bloc.dart';
import '../presentation/bloc/directorate_complaints_bloc.dart';
import '../presentation/bloc/process_details_bloc.dart';

Future<void> setupDirectorateProcessManagementInjection() async {
  if (!getIt.isRegistered<DirectorateProcessRemoteDataSource>()) {
    getIt.registerLazySingleton(
      () => DirectorateProcessRemoteDataSource(getIt<ApiService>()),
    );
  }
  if (!getIt.isRegistered<DirectorateProcessRepository>()) {
    getIt.registerLazySingleton<DirectorateProcessRepository>(
      () => DirectorateProcessRepositoryImpl(
        getIt<DirectorateProcessRemoteDataSource>(),
      ),
    );
  }
  if (!getIt.isRegistered<GetTransactionTypes>()) {
    getIt.registerLazySingleton(
      () => GetTransactionTypes(getIt<DirectorateProcessRepository>()),
    );
  }
  if (!getIt.isRegistered<GetProcessDefinitions>()) {
    getIt.registerLazySingleton(
      () => GetProcessDefinitions(getIt<DirectorateProcessRepository>()),
    );
  }
  if (!getIt.isRegistered<GetProcessDetails>()) {
    getIt.registerLazySingleton(
      () => GetProcessDetails(getIt<DirectorateProcessRepository>()),
    );
  }
  if (!getIt.isRegistered<GetComplaintProcessDefinitions>()) {
    getIt.registerLazySingleton(
      () => GetComplaintProcessDefinitions(
        getIt<DirectorateProcessRepository>(),
      ),
    );
  }
  if (!getIt.isRegistered<DirectorateProcessBloc>()) {
    getIt.registerFactory(
      () => DirectorateProcessBloc(
        getTransactionTypes: getIt<GetTransactionTypes>(),
        getProcessDefinitions: getIt<GetProcessDefinitions>(),
      ),
    );
  }
  if (!getIt.isRegistered<ProcessDetailsBloc>()) {
    getIt.registerFactory(
      () => ProcessDetailsBloc(
        getProcessDetails: getIt<GetProcessDetails>(),
      ),
    );
  }
  if (!getIt.isRegistered<DirectorateComplaintsBloc>()) {
    getIt.registerFactory(
      () => DirectorateComplaintsBloc(
        getComplaints: getIt<GetComplaintProcessDefinitions>(),
      ),
    );
  }
}
