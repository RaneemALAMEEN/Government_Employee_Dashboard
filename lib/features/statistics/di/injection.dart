import '../../../core/di/injection.dart';
import '../../../core/services/api_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../data/datasources/statistics_remote_data_source.dart';
import '../data/repositories/statistics_repository_impl.dart';
import '../domain/repositories/statistics_repository.dart';
import '../domain/usecases/get_department_employees_stats.dart';
import '../domain/usecases/get_statistics_employee_details.dart';
import '../domain/usecases/get_process_definition_stats.dart';
import '../presentation/bloc/statistics_bloc.dart';
import '../presentation/bloc/statistics_employee_details_bloc.dart';

Future<void> setupStatisticsInjection() async {
  if (!getIt.isRegistered<StatisticsRemoteDataSource>()) {
    getIt.registerLazySingleton<StatisticsRemoteDataSource>(
      () => StatisticsRemoteDataSource(
        getIt<ApiService>(),
        getIt<SecureStorageService>(),
      ),
    );
  }

  if (!getIt.isRegistered<StatisticsRepository>()) {
    getIt.registerLazySingleton<StatisticsRepository>(
      () => StatisticsRepositoryImpl(getIt<StatisticsRemoteDataSource>()),
    );
  }

  if (!getIt.isRegistered<GetDepartmentEmployeesStats>()) {
    getIt.registerLazySingleton<GetDepartmentEmployeesStats>(
      () => GetDepartmentEmployeesStats(getIt<StatisticsRepository>()),
    );
  }

  if (!getIt.isRegistered<GetProcessDefinitionStats>()) {
    getIt.registerLazySingleton<GetProcessDefinitionStats>(
      () => GetProcessDefinitionStats(getIt<StatisticsRepository>()),
    );
  }

  if (!getIt.isRegistered<GetStatisticsEmployeeDetails>()) {
    getIt.registerLazySingleton<GetStatisticsEmployeeDetails>(
      () => GetStatisticsEmployeeDetails(getIt<StatisticsRepository>()),
    );
  }

  if (!getIt.isRegistered<StatisticsBloc>()) {
    getIt.registerFactory<StatisticsBloc>(
      () => StatisticsBloc(
        getDepartmentEmployeesStats: getIt<GetDepartmentEmployeesStats>(),
        getProcessDefinitionStats: getIt<GetProcessDefinitionStats>(),
      ),
    );
  }

  if (!getIt.isRegistered<StatisticsEmployeeDetailsBloc>()) {
    getIt.registerFactory<StatisticsEmployeeDetailsBloc>(
      () => StatisticsEmployeeDetailsBloc(
        getEmployeeDetails: getIt<GetStatisticsEmployeeDetails>(),
      ),
    );
  }
}
