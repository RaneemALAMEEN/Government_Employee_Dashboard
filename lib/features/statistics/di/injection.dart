import '../../../core/di/injection.dart';
import '../../../core/services/api_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../self_cards/domain/usecases/get_employee_self_card_usecase.dart';
import '../data/datasources/statistics_remote_data_source.dart';
import '../data/repositories/statistics_repository_impl.dart';
import '../domain/repositories/statistics_repository.dart';
import '../domain/usecases/get_department_employees_stats.dart';
import '../domain/usecases/get_statistics_employee_details.dart';
import '../domain/usecases/get_process_definition_stats.dart';
import '../domain/usecases/search_employees_usecase.dart';
import '../domain/usecases/search_process_definitions_usecase.dart';
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

  if (!getIt.isRegistered<SearchEmployeesUseCase>()) {
    getIt.registerLazySingleton<SearchEmployeesUseCase>(
      () => SearchEmployeesUseCase(getIt<StatisticsRepository>()),
    );
  }

  if (!getIt.isRegistered<SearchProcessDefinitionsUseCase>()) {
    getIt.registerLazySingleton<SearchProcessDefinitionsUseCase>(
      () => SearchProcessDefinitionsUseCase(getIt<StatisticsRepository>()),
    );
  }

  if (!getIt.isRegistered<StatisticsBloc>()) {
    getIt.registerFactory<StatisticsBloc>(
      () => StatisticsBloc(
        getDepartmentEmployeesStats: getIt<GetDepartmentEmployeesStats>(),
        getProcessDefinitionStats: getIt<GetProcessDefinitionStats>(),
        searchEmployeesUseCase: getIt<SearchEmployeesUseCase>(),
        searchProcessDefinitionsUseCase:
            getIt<SearchProcessDefinitionsUseCase>(),
      ),
    );
  }

  if (!getIt.isRegistered<StatisticsEmployeeDetailsBloc>()) {
    getIt.registerFactory<StatisticsEmployeeDetailsBloc>(
      () => StatisticsEmployeeDetailsBloc(
        getEmployeeDetails: getIt<GetStatisticsEmployeeDetails>(),
        getEmployeeSelfCard: getIt<GetEmployeeSelfCardUseCase>(),
      ),
    );
  }
}
