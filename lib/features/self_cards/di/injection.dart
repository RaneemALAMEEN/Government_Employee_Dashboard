import 'package:get_it/get_it.dart';

import '../../../core/services/api_service.dart';
import '../data/datasources/self_cards_remote_data_source.dart';
import '../data/repositories/self_cards_repository_impl.dart';
import '../domain/repositories/self_cards_repository.dart';
import '../domain/usecases/get_employee_self_card_usecase.dart';
import '../domain/usecases/get_self_card_details_usecase.dart';
import '../domain/usecases/recommend_self_cards_by_training_usecase.dart';
import '../domain/usecases/search_self_cards_usecase.dart';
import '../presentation/bloc/self_cards_bloc.dart';

void setupSelfCardsInjection(GetIt getIt) {
  // Remote Data Source
  if (!getIt.isRegistered<SelfCardsRemoteDataSource>()) {
    getIt.registerLazySingleton<SelfCardsRemoteDataSource>(
      () => SelfCardsRemoteDataSource(getIt<ApiService>()),
    );
  }

  // Repository
  if (!getIt.isRegistered<SelfCardsRepository>()) {
    getIt.registerLazySingleton<SelfCardsRepository>(
      () => SelfCardsRepositoryImpl(getIt<SelfCardsRemoteDataSource>()),
    );
  }

  // UseCases
  if (!getIt.isRegistered<SearchSelfCardsUseCase>()) {
    getIt.registerLazySingleton<SearchSelfCardsUseCase>(
      () => SearchSelfCardsUseCase(getIt<SelfCardsRepository>()),
    );
  }

  if (!getIt.isRegistered<GetSelfCardDetailsUseCase>()) {
    getIt.registerLazySingleton<GetSelfCardDetailsUseCase>(
      () => GetSelfCardDetailsUseCase(getIt<SelfCardsRepository>()),
    );
  }

  if (!getIt.isRegistered<GetEmployeeSelfCardUseCase>()) {
    getIt.registerLazySingleton<GetEmployeeSelfCardUseCase>(
      () => GetEmployeeSelfCardUseCase(getIt<SelfCardsRepository>()),
    );
  }

  if (!getIt.isRegistered<RecommendSelfCardsByTrainingUseCase>()) {
    getIt.registerLazySingleton<RecommendSelfCardsByTrainingUseCase>(
      () => RecommendSelfCardsByTrainingUseCase(getIt<SelfCardsRepository>()),
    );
  }

  // BLoC
  if (!getIt.isRegistered<SelfCardsBloc>()) {
    getIt.registerFactory<SelfCardsBloc>(
      () => SelfCardsBloc(
        searchSelfCards: getIt<SearchSelfCardsUseCase>(),
        getSelfCardDetails: getIt<GetSelfCardDetailsUseCase>(),
        recommendByTraining: getIt<RecommendSelfCardsByTrainingUseCase>(),
      ),
    );
  }
}
