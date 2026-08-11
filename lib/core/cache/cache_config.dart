import 'package:flutter/foundation.dart';

/// Centralized configuration for the client caching infrastructure.
///
/// Contains default TTL (Time-To-Live) values, versioning controls,
/// and per-feature overrides. All TTL values are configurable and never hardcoded elsewhere.
@immutable
class CacheConfig {
  /// Global default TTL if feature-specific TTL is not specified.
  final Duration defaultTtl;

  /// Map of feature keys to their default TTLs.
  final Map<String, Duration> featureTtls;

  /// Active cache version. Bumping this invalidates stale cached objects across app updates.
  final int cacheVersion;

  /// Schema version for Isar database collections.
  final int schemaVersion;

  /// Maximum entries permitted in generic cache.
  final int maxCacheEntries;

  const CacheConfig({
    required this.defaultTtl,
    required this.featureTtls,
    this.cacheVersion = 1,
    this.schemaVersion = 1,
    this.maxCacheEntries = 5000,
  });

  /// Factory providing default enterprise caching configurations.
  factory CacheConfig.defaultConfig() {
    return const CacheConfig(
      defaultTtl: Duration(minutes: 5),
      featureTtls: {
        'dashboard': Duration(minutes: 2),
        'my_transactions': Duration(minutes: 1),
        'department_transactions': Duration(minutes: 1),
        'notifications': Duration.zero, // WebSocket-driven updates
        'statistics': Duration(minutes: 5),
        'employees': Duration(hours: 12),
        'organization_hierarchy': Duration(hours: 24),
        'workflow_definitions': Duration(hours: 24),
        'file_metadata': Duration(hours: 24),
      },
      cacheVersion: 1,
      schemaVersion: 1,
      maxCacheEntries: 5000,
    );
  }

  /// Gets configured TTL for a feature, or [defaultTtl] if not defined.
  Duration getTtlForFeature(String featureKey) {
    return featureTtls[featureKey] ?? defaultTtl;
  }
}
