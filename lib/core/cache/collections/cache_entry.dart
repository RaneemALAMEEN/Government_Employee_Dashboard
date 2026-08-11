import 'package:isar/isar.dart';

part 'cache_entry.g.dart';

/// Generic Isar Collection for storing summary data, application configurations,
/// feature flags, and generic key-value payloads safely isolated by user.
@collection
class CacheEntry {
  Id id = Isar.autoIncrement;

  /// Unique composite cache key (e.g. `user_123:dashboard_summary`).
  @Index(unique: true, replace: true)
  late String cacheKey;

  /// User identifier for strict user cache isolation.
  @Index()
  late String userId;

  /// Timestamp when cache record was originally created.
  late DateTime createdAt;

  /// Timestamp when cache record was last updated.
  late DateTime updatedAt;

  /// Time-To-Live duration in seconds.
  late int ttlSeconds;

  /// Active cache version for automatic schema/invalidation handling.
  late int cacheVersion;

  /// Isar schema version.
  late int schemaVersion;

  /// Content hash for change detection.
  String? dataHash;

  /// Server ETag header.
  String? etag;

  /// Remote payload version string.
  String? version;

  /// Server Last-Modified header.
  String? lastModified;

  /// Serialized JSON payload for generic/small objects.
  String? jsonData;
}
