import 'package:get_it/get_it.dart';
import 'package:government_employee_dashboard/features/internal_transactions/domain/usecases/get_document_template_usecase.dart';
import '../presentation/bloc/create_internal_transaction/create_internal_transaction_bloc.dart';
import '../../../core/services/api_service.dart';
import '../data/datasources/internal_transactions_remote_data_source.dart';
import '../data/repositories/internal_transactions_repository_impl.dart';
import '../domain/repositories/internal_transactions_repository.dart';
import '../domain/usecases/complete_signed_transaction_usecase.dart';
import '../domain/usecases/create_signing_challenge_usecase.dart';
import '../domain/usecases/get_internal_categories_usecase.dart';
import '../domain/usecases/get_my_transaction_counts_usecase.dart';
import '../domain/usecases/get_my_transactions_usecase.dart';
import '../domain/usecases/get_processes_by_category_usecase.dart';
import '../domain/usecases/get_stage_config_usecase.dart';
import '../domain/usecases/upload_transaction_file_usecase.dart';
import '../presentation/bloc/internal_transactions_bloc.dart';
import '../../../core/services/usb_signing_service.dart';
import '../presentation/bloc/internal_transaction_form/internal_transaction_form_bloc.dart';

void setupInternalTransactionsInjection(GetIt getIt) {
  if (!getIt.isRegistered<InternalTransactionsRemoteDataSource>()) {
    getIt.registerLazySingleton<InternalTransactionsRemoteDataSource>(
      () => InternalTransactionsRemoteDataSource(getIt<ApiService>()),
    );
  }

  if (!getIt.isRegistered<InternalTransactionsRepository>()) {
    getIt.registerLazySingleton<InternalTransactionsRepository>(
      () => InternalTransactionsRepositoryImpl(
        getIt<InternalTransactionsRemoteDataSource>(),
      ),
    );
  }

  if (!getIt.isRegistered<GetInternalCategoriesUseCase>()) {
    getIt.registerLazySingleton(
      () => GetInternalCategoriesUseCase(
        getIt<InternalTransactionsRepository>(),
      ),
    );
  }

  if (!getIt.isRegistered<GetProcessesByCategoryUseCase>()) {
    getIt.registerLazySingleton(
      () => GetProcessesByCategoryUseCase(
        getIt<InternalTransactionsRepository>(),
      ),
    );
  }

  if (!getIt.isRegistered<GetMyTransactionCountsUseCase>()) {
    getIt.registerLazySingleton(
      () => GetMyTransactionCountsUseCase(
        getIt<InternalTransactionsRepository>(),
      ),
    );
  }

  if (!getIt.isRegistered<GetMyTransactionsUseCase>()) {
    getIt.registerLazySingleton(
      () => GetMyTransactionsUseCase(
        getIt<InternalTransactionsRepository>(),
      ),
    );
  }

  if (!getIt.isRegistered<GetStageConfigUseCase>()) {
    getIt.registerLazySingleton(
      () => GetStageConfigUseCase(
        getIt<InternalTransactionsRepository>(),
      ),
    );
  }

  if (!getIt.isRegistered<UploadTransactionFileUseCase>()) {
    getIt.registerLazySingleton(
      () => UploadTransactionFileUseCase(
        getIt<InternalTransactionsRepository>(),
      ),
    );
  }

  if (!getIt.isRegistered<CreateSigningChallengeUseCase>()) {
    getIt.registerLazySingleton(
      () => CreateSigningChallengeUseCase(
        getIt<InternalTransactionsRepository>(),
      ),
    );
  }

  if (!getIt.isRegistered<CompleteSignedTransactionUseCase>()) {
    getIt.registerLazySingleton(
      () => CompleteSignedTransactionUseCase(
        getIt<InternalTransactionsRepository>(),
      ),
    );
  }

  if (!getIt.isRegistered<InternalTransactionsBloc>()) {
    getIt.registerFactory(
      () => InternalTransactionsBloc(
        getMyTransactionCounts: getIt<GetMyTransactionCountsUseCase>(),
        getMyTransactions: getIt<GetMyTransactionsUseCase>(),
      ),
    );
  }

  if (!getIt.isRegistered<CreateInternalTransactionBloc>()) {
    getIt.registerFactory(
      () => CreateInternalTransactionBloc(
        getInternalCategories: getIt<GetInternalCategoriesUseCase>(),
        getProcessesByCategory: getIt<GetProcessesByCategoryUseCase>(),
      ),
    );
  }
  if (!getIt.isRegistered<GetDocumentTemplateUseCase>()) {
    getIt.registerLazySingleton(
      () => GetDocumentTemplateUseCase(
        getIt<InternalTransactionsRepository>(),
      ),
    );
  }

  if (!getIt.isRegistered<UsbSigningService>()) {
    getIt.registerLazySingleton<UsbSigningService>(
      () => UsbSigningService(),
    );
  }

  if (!getIt.isRegistered<InternalTransactionFormBloc>()) {
    getIt.registerFactory(
      () => InternalTransactionFormBloc(
        getStageConfig: getIt<GetStageConfigUseCase>(),
        getDocumentTemplate: getIt<GetDocumentTemplateUseCase>(),
        uploadTransactionFile: getIt<UploadTransactionFileUseCase>(),
        createSigningChallenge: getIt<CreateSigningChallengeUseCase>(),
        completeSignedTransaction: getIt<CompleteSignedTransactionUseCase>(),
        usbSigningService: getIt<UsbSigningService>(),
      ),
    );
  }
}