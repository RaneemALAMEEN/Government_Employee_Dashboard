import '../../../core/di/injection.dart';
import '../data/datasources/employees_local_data_source.dart';
import '../data/repositories/employees_repository_impl.dart';
import '../domain/repositories/employees_repository.dart';
import '../domain/usecases/get_employee_by_id.dart';
import '../domain/usecases/get_employees.dart';
import '../presentation/bloc/employees_bloc.dart';

Future<void> setupEmployeesInjection() async {
  if (!getIt.isRegistered<EmployeesLocalDataSource>()) {
    getIt.registerLazySingleton<EmployeesLocalDataSource>(
      () => EmployeesLocalDataSource(),
    );
  }

  if (!getIt.isRegistered<EmployeesRepository>()) {
    getIt.registerLazySingleton<EmployeesRepository>(
      () => EmployeesRepositoryImpl(getIt<EmployeesLocalDataSource>()),
    );
  }

  if (!getIt.isRegistered<GetEmployees>()) {
    getIt.registerLazySingleton<GetEmployees>(
      () => GetEmployees(getIt<EmployeesRepository>()),
    );
  }

  if (!getIt.isRegistered<GetEmployeeById>()) {
    getIt.registerLazySingleton<GetEmployeeById>(
      () => GetEmployeeById(getIt<EmployeesRepository>()),
    );
  }

  if (!getIt.isRegistered<EmployeesBloc>()) {
    getIt.registerFactory<EmployeesBloc>(
      () => EmployeesBloc(
        getEmployees: getIt<GetEmployees>(),
        getEmployeeById: getIt<GetEmployeeById>(),
      ),
    );
  }
}
