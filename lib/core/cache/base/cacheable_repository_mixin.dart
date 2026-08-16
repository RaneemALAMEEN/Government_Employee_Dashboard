import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../errors/failures.dart';
import '../cache_policy.dart';
import '../cache_result.dart';
import '../services/cache_policy_executor.dart';
import '../services/user_scope_service.dart';

/// Reusable repository mixin providing clean Stale-While-Revalidate (SWR) access,
/// change detection comparison, and background synchronization helpers.
mixin CacheableRepositoryMixin {
  /// Reference to core [CachePolicyExecutor].
  CachePolicyExecutor get cachePolicyExecutor;

  /// Reference to core [UserScopeService].
  UserScopeService get userScopeService;

  /// Executes a request applying the specified [policy].
  ///
  /// For [CachePolicy.staleWhileRevalidate]:
  /// Returns cached data instantly if present (tagged with [DataFreshnessStatus]),
  /// then triggers a silent background refresh via [networkCall].
  /// If data has changed, updates cache and invokes optional [onBackgroundDataUpdated].
  Future<Either<Failure, CacheResult<T>>> executeCachedRequest<T>({
    required String featureKey,
    required String rawCacheKey,
    required CachePolicy policy,
    required Future<T> Function() networkCall,
    required T Function(String json) fromJson,
    required String Function(T data) toJson,
    void Function(T newData)? onBackgroundDataUpdated,
    Duration? customTtl,
  }) async {
    final scopedKey = userScopeService.buildScopedKey(rawCacheKey);

    try {
      final result = await cachePolicyExecutor.execute<T>(
        featureKey: featureKey,
        cacheKey: scopedKey,
        policy: policy,
        networkCall: networkCall,
        fromJson: fromJson,
        toJson: toJson,
        onBackgroundUpdated: onBackgroundDataUpdated,
        customTtl: customTtl,
      );

      return Right(result);
    } catch (e) {
      debugPrint('CacheableRepositoryMixin error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
