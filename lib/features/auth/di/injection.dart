import '../../../core/di/injection.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/session_service.dart';
import '../../../core/services/usb_signing_service.dart';
import '../../../core/storage/secure_storage_service.dart';


import '../data/datasources/auth_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/change_pin_usecase.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/verify_app_pin_usecase.dart';
import '../domain/usecases/verify_otp_usecase.dart';
import '../presentation/bloc/login/login_bloc.dart';
import '../presentation/bloc/otp/otp_bloc.dart';

Future<void> setupAuthInjection() async {
  if (!getIt.isRegistered<AuthRemoteDataSource>()) {
    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(getIt<ApiService>()),
    );
  }

  if (!getIt.isRegistered<AuthRepository>()) {
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        getIt<AuthRemoteDataSource>(),
        getIt<SecureStorageService>(),
      ),
    );
  }

  if (!getIt.isRegistered<LoginUseCase>()) {
    getIt.registerLazySingleton<LoginUseCase>(
      () => LoginUseCase(getIt<AuthRepository>()),
    );
  }

  if (!getIt.isRegistered<VerifyOtpUseCase>()) {
    getIt.registerLazySingleton<VerifyOtpUseCase>(
      () => VerifyOtpUseCase(getIt<AuthRepository>()),
    );
  }

  if (!getIt.isRegistered<VerifyAppPinUseCase>()) {
    getIt.registerLazySingleton<VerifyAppPinUseCase>(
      () => VerifyAppPinUseCase(getIt<AuthRepository>()),
    );
  }

  if (!getIt.isRegistered<ChangePinUseCase>()) {
    getIt.registerLazySingleton<ChangePinUseCase>(
      () => ChangePinUseCase(
        repository: getIt<AuthRepository>(),
        usbSigningService: getIt<UsbSigningService>(),
        sessionService: getIt<SessionService>(),
      ),
    );
  }


  getIt.registerFactory<LoginBloc>(
    () => LoginBloc(getIt<LoginUseCase>()),
  );

  getIt.registerFactory<OtpBloc>(
    () => OtpBloc(getIt<VerifyOtpUseCase>()),
  );
}