import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../cache_policy.dart';
import '../cache_result.dart';
import '../change_detection_strategy.dart';
import '../data_freshness_status.dart';
import 'cache_manager.dart';
import 'ttl_manager.dart';

/// Strategy execution engine that orchestrates fetching and caching
/// based on configured [CachePolicy].
class CachePolicyExecutor {
  final CacheManager cacheManager;
  final TTLManager ttlManager;
  final ChangeDetectionStrategy changeDetection;

  const CachePolicyExecutor({
    required this.cacheManager,
    required this.ttlManager,
    this.changeDetection = const ChangeDetectionStrategy(),
  });

  /// Executes a cached query using the provided [policy].
  Future<CacheResult<T>> execute<T>({
    required String featureKey,
    required String cacheKey,
    required CachePolicy policy,
    required Future<T> Function() networkCall,
    required T Function(String json) fromJson,
    required String Function(T data) toJson,
    void Function(T newData)? onBackgroundUpdated,
    Duration? customTtl,
  }) async {
    final effectiveTtl = customTtl ?? ttlManager.getTtlForFeature(featureKey);

    switch (policy) {
      case CachePolicy.staleWhileRevalidate:
        return _executeStaleWhileRevalidate<T>(
          featureKey: featureKey,
          cacheKey: cacheKey,
          networkCall: networkCall,
          fromJson: fromJson,
          toJson: toJson,
          onBackgroundUpdated: onBackgroundUpdated,
          ttl: effectiveTtl,
        );

      case CachePolicy.cacheFirst:
        return _executeCacheFirst<T>(
          featureKey: featureKey,
          cacheKey: cacheKey,
          networkCall: networkCall,
          fromJson: fromJson,
          toJson: toJson,
          ttl: effectiveTtl,
        );

      case CachePolicy.networkFirst:
        return _executeNetworkFirst<T>(
          featureKey: featureKey,
          cacheKey: cacheKey,
          networkCall: networkCall,
          fromJson: fromJson,
          toJson: toJson,
          ttl: effectiveTtl,
        );

      case CachePolicy.cacheOnly:
        return _executeCacheOnly<T>(
          cacheKey: cacheKey,
          fromJson: fromJson,
        );

      case CachePolicy.networkOnly:
        return _executeNetworkOnly<T>(
          cacheKey: cacheKey,
          networkCall: networkCall,
          toJson: toJson,
          ttl: effectiveTtl,
        );
    }
  }

  Future<CacheResult<T>> _executeStaleWhileRevalidate<T>({
    required String featureKey,
    required String cacheKey,
    required Future<T> Function() networkCall,
    required T Function(String json) fromJson,
    required String Function(T data) toJson,
    void Function(T newData)? onBackgroundUpdated,
    required Duration ttl,
  }) async {
    final rawEntry = await cacheManager.readRawEntry(cacheKey);

    if (rawEntry != null && rawEntry.jsonData != null) {
      final isStale = ttlManager.isExpired(rawEntry);
      final cachedData = fromJson(rawEntry.jsonData!);

      // Trigger silent background refresh if stale or missing recent network verification
      _triggerBackgroundRefresh<T>(
        cacheKey: cacheKey,
        rawEntryHash: rawEntry.dataHash,
        rawEntryEtag: rawEntry.etag,
        rawEntryVersion: rawEntry.version,
        rawEntryLastModified: rawEntry.lastModified,
        networkCall: networkCall,
        toJson: toJson,
        onBackgroundUpdated: onBackgroundUpdated,
        ttl: ttl,
      );

      return CacheResult<T>(
        data: cachedData,
        freshnessStatus: isStale
            ? DataFreshnessStatus.stale
            : DataFreshnessStatus.cached,
        cacheKey: cacheKey,
        cachedAt: rawEntry.updatedAt,
        isStale: isStale,
        etag: rawEntry.etag,
        version: rawEntry.version,
        contentHash: rawEntry.dataHash,
      );
    }

    // No cache exists → must fetch network synchronously
    final freshData = await networkCall();
    final jsonStr = toJson(freshData);
    final hash = changeDetection.generateHash(jsonStr);

    await cacheManager.write<T>(
      cacheKey: cacheKey,
      data: freshData,
      toJson: (item) => jsonDecode(jsonStr) as Map<String, dynamic>,
      ttl: ttl,
      dataHash: hash,
    );

    return CacheResult<T>(
      data: freshData,
      freshnessStatus: DataFreshnessStatus.fresh,
      cacheKey: cacheKey,
      cachedAt: DateTime.now(),
      isStale: false,
      contentHash: hash,
    );
  }

  void _triggerBackgroundRefresh<T>({
    required String cacheKey,
    required String? rawEntryHash,
    required String? rawEntryEtag,
    required String? rawEntryVersion,
    required String? rawEntryLastModified,
    required Future<T> Function() networkCall,
    required String Function(T data) toJson,
    void Function(T newData)? onBackgroundUpdated,
    required Duration ttl,
  }) {
    Future.microtask(() async {
      try {
        final remoteData = await networkCall();
        final remoteJsonStr = toJson(remoteData);
        final newHash = changeDetection.generateHash(remoteJsonStr);

        final changed = changeDetection.hasChanged(
          cachedEtag: rawEntryEtag,
          remoteEtag: null,
          cachedVersion: rawEntryVersion,
          remoteVersion: null,
          cachedLastModified: rawEntryLastModified,
          remoteLastModified: null,
          cachedHash: rawEntryHash,
          remoteDataJson: remoteJsonStr,
        );

        if (changed) {
          debugPrint('[CachePolicyExecutor] Background refresh detected changes for: $cacheKey');
          await cacheManager.write<T>(
            cacheKey: cacheKey,
            data: remoteData,
            toJson: (item) => jsonDecode(remoteJsonStr) as Map<String, dynamic>,
            ttl: ttl,
            dataHash: newHash,
          );

          if (onBackgroundUpdated != null) {
            onBackgroundUpdated(remoteData);
          }
        } else {
          debugPrint('[CachePolicyExecutor] Background refresh: Data unchanged for $cacheKey.');
        }
      } catch (e) {
        debugPrint('[CachePolicyExecutor] Background refresh error for $cacheKey: $e');
      }
    });
  }

  Future<CacheResult<T>> _executeCacheFirst<T>({
    required String featureKey,
    required String cacheKey,
    required Future<T> Function() networkCall,
    required T Function(String json) fromJson,
    required String Function(T data) toJson,
    required Duration ttl,
  }) async {
    final rawEntry = await cacheManager.readRawEntry(cacheKey);

    if (rawEntry != null && rawEntry.jsonData != null && !ttlManager.isExpired(rawEntry)) {
      return CacheResult<T>(
        data: fromJson(rawEntry.jsonData!),
        freshnessStatus: DataFreshnessStatus.cached,
        cacheKey: cacheKey,
        cachedAt: rawEntry.updatedAt,
      );
    }

    return _fetchAndCache<T>(
      cacheKey: cacheKey,
      networkCall: networkCall,
      toJson: toJson,
      ttl: ttl,
    );
  }

  Future<CacheResult<T>> _executeNetworkFirst<T>({
    required String featureKey,
    required String cacheKey,
    required Future<T> Function() networkCall,
    required T Function(String json) fromJson,
    required String Function(T data) toJson,
    required Duration ttl,
  }) async {
    try {
      return await _fetchAndCache<T>(
        cacheKey: cacheKey,
        networkCall: networkCall,
        toJson: toJson,
        ttl: ttl,
      );
    } catch (_) {
      final rawEntry = await cacheManager.readRawEntry(cacheKey);
      if (rawEntry != null && rawEntry.jsonData != null) {
        return CacheResult<T>(
          data: fromJson(rawEntry.jsonData!),
          freshnessStatus: DataFreshnessStatus.offline,
          cacheKey: cacheKey,
          cachedAt: rawEntry.updatedAt,
          isStale: true,
        );
      }
      rethrow;
    }
  }

  Future<CacheResult<T>> _executeCacheOnly<T>({
    required String cacheKey,
    required T Function(String json) fromJson,
  }) async {
    final rawEntry = await cacheManager.readRawEntry(cacheKey);
    if (rawEntry != null && rawEntry.jsonData != null) {
      return CacheResult<T>(
        data: fromJson(rawEntry.jsonData!),
        freshnessStatus: DataFreshnessStatus.cached,
        cacheKey: cacheKey,
        cachedAt: rawEntry.updatedAt,
        isStale: ttlManager.isExpired(rawEntry),
      );
    }
    throw StateError('No cached entry available for key: $cacheKey');
  }

  Future<CacheResult<T>> _executeNetworkOnly<T>({
    required String cacheKey,
    required Future<T> Function() networkCall,
    required String Function(T data) toJson,
    required Duration ttl,
  }) async {
    return _fetchAndCache<T>(
      cacheKey: cacheKey,
      networkCall: networkCall,
      toJson: toJson,
      ttl: ttl,
    );
  }

  Future<CacheResult<T>> _fetchAndCache<T>({
    required String cacheKey,
    required Future<T> Function() networkCall,
    required String Function(T data) toJson,
    required Duration ttl,
  }) async {
    final freshData = await networkCall();
    final jsonStr = toJson(freshData);
    final hash = changeDetection.generateHash(jsonStr);

    await cacheManager.write<T>(
      cacheKey: cacheKey,
      data: freshData,
      toJson: (item) => jsonDecode(jsonStr) as Map<String, dynamic>,
      ttl: ttl,
      dataHash: hash,
    );

    return CacheResult<T>(
      data: freshData,
      freshnessStatus: DataFreshnessStatus.fresh,
      cacheKey: cacheKey,
      cachedAt: DateTime.now(),
      contentHash: hash,
    );
  }
}
