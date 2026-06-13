// import '../../../core/di/injection.dart';

// import '../data/datasources/transactions_local_data_source.dart';
// import '../data/repositories/dashboard_repository_impl.dart';
// import '../domain/repositories/dashboard_repository.dart';
// import '../domain/usecases/get_dashboard_data.dart';
// import '../presentation/bloc/dashboard_bloc.dart';

// Future<void> setupDashboardInjection() async {
//   if (!getIt.isRegistered<DashboardLocalDataSource>()) {
//     getIt.registerLazySingleton<DashboardLocalDataSource>(
//       () => DashboardLocalDataSource(),
//     );
//   }

//   if (!getIt.isRegistered<DashboardRepository>()) {
//     getIt.registerLazySingleton<DashboardRepository>(
//       () => DashboardRepositoryImpl(getIt<DashboardLocalDataSource>()),
//     );
//   }

//   if (!getIt.isRegistered<GetDashboardData>()) {
//     getIt.registerLazySingleton<GetDashboardData>(
//       () => GetDashboardData(getIt<DashboardRepository>()),
//     );
//   }

//   getIt.registerFactory<DashboardBloc>(
//     () => DashboardBloc(getIt<GetDashboardData>()),
//   );
// }