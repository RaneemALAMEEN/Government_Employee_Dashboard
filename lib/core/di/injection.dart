import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../features/internal_transactions/di/injection.dart';
import '../network/dio_client.dart';
import '../services/api_service.dart';
import '../services/push_socket.dart';
import '../services/session_service.dart';
import '../services/token_refresh_service.dart';
import '../storage/secure_storage_service.dart';

final getIt = GetIt.instance;

Future<void> setupCoreInjection() async {
  if (!getIt.isRegistered<SecureStorageService>()) {
    getIt.registerLazySingleton<SecureStorageService>(
      () => SecureStorageService(),
    );
  }

  if (!getIt.isRegistered<SessionService>()) {
    getIt.registerLazySingleton<SessionService>(
      () => SessionService(getIt<SecureStorageService>()),
    );
  }

  // خدمة تجديد التوكن المشتركة. تُسجَّل قبل Dio لأن AuthInterceptor (المُنشأ
  // داخل DioClient.create) يحتاجها. Singleton كي يتشارك تنسيقها (coalescing)
  // مع PushSocket — فلا يقع تجديد مزدوج بين 401 وإعادة اتصال الـ socket.
  if (!getIt.isRegistered<TokenRefreshService>()) {
    getIt.registerLazySingleton<TokenRefreshService>(
      () => TokenRefreshService(storage: getIt<SecureStorageService>()),
    );
  }

  if (!getIt.isRegistered<Dio>()) {
    getIt.registerLazySingleton<Dio>(
      () => DioClient.create(
        getIt<SecureStorageService>(),
        getIt<TokenRefreshService>(),
      ),
    );
  }


  if (!getIt.isRegistered<ApiService>()) {
    getIt.registerLazySingleton<ApiService>(
      () => ApiService(getIt<Dio>()),
    );
  }

  // اتصال إشعارات الـ WebSocket (بديل FCM على سطح مكتب Windows). يُبدأ صراحةً
  // من main عبر start() بعد تهيئة الإشعارات والـ tray.
  if (!getIt.isRegistered<PushSocket>()) {
    getIt.registerLazySingleton<PushSocket>(
      () => PushSocket(
        storage: getIt<SecureStorageService>(),
        refreshService: getIt<TokenRefreshService>(),
      ),
    );
  }

    setupInternalTransactionsInjection(getIt);
}