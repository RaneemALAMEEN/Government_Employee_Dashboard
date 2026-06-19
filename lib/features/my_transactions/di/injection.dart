import '../../../core/di/injection.dart';
import '../../../core/services/api_service.dart';
import '../data/datasources/my_transactions_remote_data_source.dart';
import '../data/repositories/my_transactions_repository_impl.dart';
import '../domain/repositories/my_transactions_repository.dart';
import '../domain/usecases/get_my_transactions.dart';
import '../presentation/bloc/my_transactions_bloc.dart';

Future<void> setupMyTransactionsInjection() async {
  if (!getIt.isRegistered<MyTransactionsRemoteDataSource>()) {
    getIt.registerLazySingleton<MyTransactionsRemoteDataSource>(
      () => MyTransactionsRemoteDataSource(getIt<ApiService>()),
    );
  }

  if (!getIt.isRegistered<MyTransactionsRepository>()) {
    getIt.registerLazySingleton<MyTransactionsRepository>(
      () => MyTransactionsRepositoryImpl(getIt<MyTransactionsRemoteDataSource>()),
    );
  }

  if (!getIt.isRegistered<GetMyTransactions>()) {
    getIt.registerLazySingleton<GetMyTransactions>(
      () => GetMyTransactions(getIt<MyTransactionsRepository>()),
    );
  }

  if (!getIt.isRegistered<MyTransactionsBloc>()) {
    getIt.registerFactory<MyTransactionsBloc>(
      () => MyTransactionsBloc(getIt<GetMyTransactions>()),
    );
  }
}
