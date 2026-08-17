import '../../../core/di/injection.dart';
import '../../../core/services/api_service.dart';
import '../../department_transactions/data/datasources/department_transactions_remote_data_source.dart';
import '../../department_transactions/data/repositories/department_transactions_repository_impl.dart';
import '../../department_transactions/domain/repositories/department_transactions_repository.dart';
import '../../department_transactions/domain/usecases/get_accessible_departments.dart';
import '../../department_transactions/domain/usecases/get_department_transactions.dart';
import '../../department_transactions/domain/usecases/get_department_stats.dart';
import '../../department_transactions/presentation/bloc/dept_tx_bloc.dart';
import '../../department_transactions/presentation/bloc/certificate_details/department_certificate_bloc.dart';
import '../../department_transactions/presentation/bloc/final_document_generator/final_document_generator_cubit.dart';

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

  if (!getIt.isRegistered<GetDepartmentStats>()) {
    getIt.registerLazySingleton<GetDepartmentStats>(
      () => GetDepartmentStats(getIt<DepartmentTransactionsRepository>()),
    );
  }

  if (!getIt.isRegistered<GetAccessibleDepartments>()) {
    getIt.registerLazySingleton<GetAccessibleDepartments>(
      () => GetAccessibleDepartments(getIt<DepartmentTransactionsRepository>()),
    );
  }

  if (!getIt.isRegistered<DeptTxBloc>()) {
    getIt.registerFactory<DeptTxBloc>(
      () => DeptTxBloc(
        getIt<GetDepartmentTransactions>(),
        getIt<GetDepartmentStats>(),
        getIt<GetAccessibleDepartments>(),
      ),
    );
  }

  if (!getIt.isRegistered<DepartmentCertificateBloc>()) {
    getIt.registerFactory<DepartmentCertificateBloc>(
      () => DepartmentCertificateBloc(repository: getIt<DepartmentTransactionsRepository>()),
    );
  }

  if (!getIt.isRegistered<FinalDocumentGeneratorCubit>()) {
    getIt.registerFactory<FinalDocumentGeneratorCubit>(
      () => FinalDocumentGeneratorCubit(repository: getIt<DepartmentTransactionsRepository>()),
    );
  }
}

