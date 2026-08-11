import 'package:flutter/foundation.dart';
import 'data_freshness_status.dart';

/// Generic result wrapper for cache & repository requests.
///
/// Contains the payload [data], source/freshness metadata [freshnessStatus],
/// timestamps, and headers used for change detection.
@immutable
class CacheResult<T> {
  /// The payload object or list.
  final T data;

  /// Indicates whether data is fresh, cached, stale, or retrieved offline.
  final DataFreshnessStatus freshnessStatus;

  /// Timestamp when data was written to local storage.
  final DateTime? cachedAt;

  /// Flag indicating whether the cached data is past its TTL.
  final bool isStale;

  /// Unique cache key associated with this result.
  final String cacheKey;

  /// Server-provided ETag header for conditional request validation.
  final String? etag;

  /// Server-provided or payload version identifier.
  final String? version;

  /// Server-provided Last-Modified header value.
  final String? lastModified;

  /// Hash of the cached dataset for content-change verification.
  final String? contentHash;

  const CacheResult({
    required this.data,
    required this.freshnessStatus,
    required this.cacheKey,
    this.cachedAt,
    this.isStale = false,
    this.etag,
    this.version,
    this.lastModified,
    this.contentHash,
  });

  /// True if data comes from local cache (either valid or stale).
  bool get isFromCache =>
      freshnessStatus == DataFreshnessStatus.cached ||
      freshnessStatus == DataFreshnessStatus.stale ||
      freshnessStatus == DataFreshnessStatus.offline;

  /// Creates a copy of [CacheResult] with updated fields.
  CacheResult<T> copyWith({
    T? data,
    DataFreshnessStatus? freshnessStatus,
    DateTime? cachedAt,
    bool? isStale,
    String? cacheKey,
    String? etag,
    String? version,
    String? lastModified,
    String? contentHash,
  }) {
    return CacheResult<T>(
      data: data ?? this.data,
      freshnessStatus: freshnessStatus ?? this.freshnessStatus,
      cacheKey: cacheKey ?? this.cacheKey,
      cachedAt: cachedAt ?? this.cachedAt,
      isStale: isStale ?? this.isStale,
      etag: etag ?? this.etag,
      version: version ?? this.version,
      lastModified: lastModified ?? this.lastModified,
      contentHash: contentHash ?? this.contentHash,
    );
  }
}
