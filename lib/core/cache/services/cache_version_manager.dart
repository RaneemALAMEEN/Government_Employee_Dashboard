import '../cache_config.dart';
import '../collections/cache_entry.dart';

/// Manager for validating schema and cache data versions.
///
/// Prevents reading incompatible cached payloads when models or schemas update
/// across application versions.
class CacheVersionManager {
  final CacheConfig config;

  const CacheVersionManager(this.config);

  /// Validates whether a [CacheEntry] matches current active system versions.
  bool isValidVersion(CacheEntry entry) {
    final matchesCacheVersion = entry.cacheVersion == config.cacheVersion;
    final matchesSchemaVersion = entry.schemaVersion == config.schemaVersion;
    return matchesCacheVersion && matchesSchemaVersion;
  }

  /// Gets current global cache version.
  int get currentCacheVersion => config.cacheVersion;

  /// Gets current schema version.
  int get currentSchemaVersion => config.schemaVersion;
}
