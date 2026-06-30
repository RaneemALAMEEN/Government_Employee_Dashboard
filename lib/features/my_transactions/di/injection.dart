import '../../../core/di/injection.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/usb_signing_service.dart';
import '../data/datasources/my_transactions_remote_data_source.dart';
import '../data/repositories/my_transactions_repository_impl.dart';
import '../domain/repositories/my_transactions_repository.dart';
import '../domain/usecases/get_my_transactions.dart';
import '../domain/usecases/get_task_details.dart';
import '../domain/usecases/pickup_task.dart';
import '../domain/usecases/release_task.dart';
import '../domain/usecases/submit_transaction.dart';
import '../presentation/bloc/my_transactions_bloc.dart';
import '../presentation/bloc/transaction_details/transaction_details_bloc.dart';

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

  // UseCases
  if (!getIt.isRegistered<GetMyTransactions>()) {
    getIt.registerLazySingleton<GetMyTransactions>(
      () => GetMyTransactions(getIt<MyTransactionsRepository>()),
    );
  }

  if (!getIt.isRegistered<GetTaskDetails>()) {
    getIt.registerLazySingleton<GetTaskDetails>(
      () => GetTaskDetails(getIt<MyTransactionsRepository>()),
    );
  }

  if (!getIt.isRegistered<PickupTask>()) {
    getIt.registerLazySingleton<PickupTask>(
      () => PickupTask(getIt<MyTransactionsRepository>()),
    );
  }

  if (!getIt.isRegistered<ReleaseTask>()) {
    getIt.registerLazySingleton<ReleaseTask>(
      () => ReleaseTask(getIt<MyTransactionsRepository>()),
    );
  }

  if (!getIt.isRegistered<SubmitTransaction>()) {
    getIt.registerLazySingleton<SubmitTransaction>(
      () => SubmitTransaction(getIt<MyTransactionsRepository>(), UsbSigningService()),
    );
  }

  // BLoCs
  if (!getIt.isRegistered<MyTransactionsBloc>()) {
    getIt.registerFactory<MyTransactionsBloc>(
      () => MyTransactionsBloc(getIt<GetMyTransactions>()),
    );
  }

  if (!getIt.isRegistered<TransactionDetailsBloc>()) {
    getIt.registerFactory<TransactionDetailsBloc>(
      () => TransactionDetailsBloc(
        getTaskDetails: getIt<GetTaskDetails>(),
        pickupTask: getIt<PickupTask>(),
        releaseTask: getIt<ReleaseTask>(),
        submitTransaction: getIt<SubmitTransaction>(),
      ),
    );
  }
}

