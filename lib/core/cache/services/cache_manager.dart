import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../collections/cache_entry.dart';
import 'cache_version_manager.dart';
import 'isar_service.dart';
import 'ttl_manager.dart';
import 'user_scope_service.dart';

/// Central orchestrator for reading, writing, invalidating, and scoping
/// client-side cached data. Independent from UI and feature business logic.
class CacheManager {
  final IsarService isarService;
  final TTLManager ttlManager;
  final CacheVersionManager versionManager;
  final UserScopeService userScope;

  CacheManager({
    required this.isarService,
    required this.ttlManager,
    required this.versionManager,
    required this.userScope,
  });

  /// Reads a cached entry by key, validating version and TTL freshness.
  Future<CacheEntry?> readRawEntry(String cacheKey) async {
    final isar = isarService.isar;
    final entry = await isar.cacheEntrys
        .filter()
        .cacheKeyEqualTo(cacheKey)
        .findFirst();

    if (entry == null) return null;

    // Check version compatibility
    if (!versionManager.isValidVersion(entry)) {
      debugPrint('[CacheManager] Version mismatch for key: $cacheKey. Invalidating.');
      await invalidate(cacheKey);
      return null;
    }

    return entry;
  }

  /// Deserializes and reads a cached object of type [T].
  Future<T?> read<T>({
    required String cacheKey,
    required T Function(Map<String, dynamic> json) fromJson,
  }) async {
    final entry = await readRawEntry(cacheKey);
    if (entry == null || entry.jsonData == null) return null;

    try {
      final jsonMap = jsonDecode(entry.jsonData!) as Map<String, dynamic>;
      return fromJson(jsonMap);
    } catch (e) {
      debugPrint('[CacheManager] Deserialization error for key $cacheKey: $e');
      await invalidate(cacheKey);
      return null;
    }
  }

  /// Writes or updates a cached object of type [T].
  Future<void> write<T>({
    required String cacheKey,
    required T data,
    required Map<String, dynamic> Function(T item) toJson,
    Duration? ttl,
    String? etag,
    String? version,
    String? lastModified,
    String? dataHash,
  }) async {
    final isar = isarService.isar;
    final userId = userScope.getCurrentUserId();
    final jsonString = jsonEncode(toJson(data));

    final existing = await isar.cacheEntrys
        .filter()
        .cacheKeyEqualTo(cacheKey)
        .findFirst();

    final now = DateTime.now();
    final entry = existing ?? CacheEntry()
      ..createdAt = now;

    entry.cacheKey = cacheKey;
    entry.userId = userId;
    entry.updatedAt = now;
    entry.ttlSeconds = (ttl ?? ttlManager.config.defaultTtl).inSeconds;
    entry.cacheVersion = versionManager.currentCacheVersion;
    entry.schemaVersion = versionManager.currentSchemaVersion;
    entry.jsonData = jsonString;
    entry.etag = etag;
    entry.version = version;
    entry.lastModified = lastModified;
    entry.dataHash = dataHash;

    await isar.writeTxn(() async {
      await isar.cacheEntrys.put(entry);
    });

    debugPrint('[CacheManager] Wrote cache entry for key: $cacheKey');
  }

  /// Checks if a valid, non-expired cache entry exists for [cacheKey].
  Future<bool> exists(String cacheKey) async {
    final entry = await readRawEntry(cacheKey);
    if (entry == null) return false;
    return !ttlManager.isExpired(entry);
  }

  /// Invalidates (deletes) a specific cache key.
  Future<void> invalidate(String cacheKey) async {
    final isar = isarService.isar;
    final entry = await isar.cacheEntrys
        .filter()
        .cacheKeyEqualTo(cacheKey)
        .findFirst();

    if (entry != null) {
      await isar.writeTxn(() async {
        await isar.cacheEntrys.delete(entry.id);
      });
      debugPrint('[CacheManager] Invalidated key: $cacheKey');
    }
  }

  /// Invalidates all entries matching a key prefix.
  Future<void> invalidateByPrefix(String prefix) async {
    final isar = isarService.isar;
    final entries = await isar.cacheEntrys.where().findAll();
    final toDelete = entries
        .where((e) => e.cacheKey.contains(prefix))
        .map((e) => e.id)
        .toList();

    if (toDelete.isNotEmpty) {
      await isar.writeTxn(() async {
        await isar.cacheEntrys.deleteAll(toDelete);
      });
    }
  }

  /// Clears ALL cached entries belonging strictly to the logged-in user.
  Future<void> clearUserCache() async {
    final userId = userScope.getCurrentUserId();
    final isar = isarService.isar;
    final entries = await isar.cacheEntrys
        .filter()
        .userIdEqualTo(userId)
        .findAll();
    final ids = entries.map((e) => e.id).toList();

    if (ids.isNotEmpty) {
      await isar.writeTxn(() async {
        await isar.cacheEntrys.deleteAll(ids);
      });
      debugPrint('[CacheManager] Cleared ${ids.length} entries for user $userId');
    }
  }

  /// Clears all database records across all users.
  Future<void> clearAll() async {
    final isar = isarService.isar;
    await isar.writeTxn(() async {
      await isar.cacheEntrys.clear();
    });
  }
}
