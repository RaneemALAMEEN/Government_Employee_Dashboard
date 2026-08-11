import '../cache_config.dart';
import '../collections/cache_entry.dart';

/// Reusable manager handling Time-To-Live (TTL) computations, cache age
/// determination, and expiration checking based on [CacheConfig].
class TTLManager {
  final CacheConfig config;

  const TTLManager(this.config);

  /// Returns the configured TTL for a specific feature key.
  Duration getTtlForFeature(String featureKey) {
    return config.getTtlForFeature(featureKey);
  }

  /// Calculates how long ago a [CacheEntry] was updated or created.
  Duration getCacheAge(CacheEntry entry) {
    final referenceTime = entry.updatedAt;
    return DateTime.now().difference(referenceTime);
  }

  /// Evaluates whether a [CacheEntry] has passed its configured TTL.
  bool isExpired(CacheEntry entry) {
    if (entry.ttlSeconds == 0) {
      // TTL == 0 indicates infinite / WebSocket-managed validity
      return false;
    }
    final age = getCacheAge(entry);
    return age.inSeconds >= entry.ttlSeconds;
  }

  /// Evaluates whether a cache entry is stale (expired but still available for SWR).
  bool isStale(CacheEntry entry) {
    return isExpired(entry);
  }

  /// Computes remaining seconds before expiration.
  int getRemainingTtlSeconds(CacheEntry entry) {
    if (entry.ttlSeconds == 0) return 999999999;
    final ageSeconds = getCacheAge(entry).inSeconds;
    final remaining = entry.ttlSeconds - ageSeconds;
    return remaining > 0 ? remaining : 0;
  }
}
