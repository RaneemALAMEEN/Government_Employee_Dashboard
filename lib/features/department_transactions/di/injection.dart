import '../../../core/di/injection.dart';
import '../../../core/services/api_service.dart';
import '../../department_transactions/data/datasources/department_transactions_remote_data_source.dart';
import '../../department_transactions/data/repositories/department_transactions_repository_impl.dart';
import '../../department_transactions/domain/repositories/department_transactions_repository.dart';
import '../../department_transactions/domain/usecases/get_department_transactions.dart';
import '../../department_transactions/presentation/bloc/dept_tx_bloc.dart';

Future<void> setupDepartmentTransactionsInjection() async {
  if (!getIt.isRegistered<DepartmentTransactionsRemoteDataSource>()) {
    getIt.registerLazySingleton<DepartmentTransactionsRemoteDataSource>(
      () => DepartmentTransactionsRemoteDataSource(getIt<ApiService>()),
    );
  }

  if (!getIt.isRegistered<DepartmentTransactionsRepository>()) {
    getIt.registerLazySingleton<DepartmentTransactionsRepository>(
      () => DepartmentTransactionsRepositoryImpl(getIt<DepartmentTransactionsRemoteDataSource>()),
    );
  }

  if (!getIt.isRegistered<GetDepartmentTransactions>()) {
    getIt.registerLazySingleton<GetDepartmentTransactions>(
      () => GetDepartmentTransactions(getIt<DepartmentTransactionsRepository>()),
    );
  }

  if (!getIt.isRegistered<DeptTxBloc>()) {
    getIt.registerFactory<DeptTxBloc>(
      () => DeptTxBloc(getIt<GetDepartmentTransactions>()),
    );
  }
}
