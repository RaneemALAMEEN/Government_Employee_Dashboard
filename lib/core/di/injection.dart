import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../features/internal_transactions/di/injection.dart';
import '../../features/appointments/di/injection.dart';
import '../../features/self_cards/di/injection.dart';
import '../cache/cache_config.dart';
import '../cache/change_detection_strategy.dart';
import '../cache/services/cache_manager.dart';
import '../cache/services/cache_policy_executor.dart';
import '../cache/services/cache_version_manager.dart';
import '../cache/services/file_cache_manager.dart';
import '../cache/services/isar_service.dart';
import '../cache/services/ttl_manager.dart';
import '../cache/services/user_scope_service.dart';
import '../cache/services/websocket_cache_sync_bus.dart';
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

  // === Client Caching Infrastructure Services (Feature-Agnostic) ===
  if (!getIt.isRegistered<CacheConfig>()) {
    getIt.registerLazySingleton<CacheConfig>(
      () => CacheConfig.defaultConfig(),
    );
  }

  if (!getIt.isRegistered<IsarService>()) {
    getIt.registerLazySingleton<IsarService>(
      () => IsarService(),
    );
  }

  if (!getIt.isRegistered<UserScopeService>()) {
    getIt.registerLazySingleton<UserScopeService>(
      () => UserScopeService(getIt<SessionService>()),
    );
  }

  if (!getIt.isRegistered<TTLManager>()) {
    getIt.registerLazySingleton<TTLManager>(
      () => TTLManager(getIt<CacheConfig>()),
    );
  }

  if (!getIt.isRegistered<CacheVersionManager>()) {
    getIt.registerLazySingleton<CacheVersionManager>(
      () => CacheVersionManager(getIt<CacheConfig>()),
    );
  }

  if (!getIt.isRegistered<CacheManager>()) {
    getIt.registerLazySingleton<CacheManager>(
      () => CacheManager(
        isarService: getIt<IsarService>(),
        ttlManager: getIt<TTLManager>(),
        versionManager: getIt<CacheVersionManager>(),
        userScope: getIt<UserScopeService>(),
      ),
    );
  }

  if (!getIt.isRegistered<ChangeDetectionStrategy>()) {
    getIt.registerLazySingleton<ChangeDetectionStrategy>(
      () => const ChangeDetectionStrategy(),
    );
  }

  if (!getIt.isRegistered<CachePolicyExecutor>()) {
    getIt.registerLazySingleton<CachePolicyExecutor>(
      () => CachePolicyExecutor(
        cacheManager: getIt<CacheManager>(),
        ttlManager: getIt<TTLManager>(),
        changeDetection: getIt<ChangeDetectionStrategy>(),
      ),
    );
  }

  if (!getIt.isRegistered<FileCacheManager>()) {
    getIt.registerLazySingleton<FileCacheManager>(
      () => FileCacheManager(
        isarService: getIt<IsarService>(),
        userScope: getIt<UserScopeService>(),
      ),
    );
  }

  if (!getIt.isRegistered<WebSocketCacheSyncBus>()) {
    getIt.registerLazySingleton<WebSocketCacheSyncBus>(
      () => WebSocketCacheSyncBus(
        cacheManager: getIt<CacheManager>(),
      ),
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
  setupAppointmentsInjection(getIt);
  setupSelfCardsInjection(getIt);
}
