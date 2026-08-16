/// Cache strategy policies supported by the client caching infrastructure.
enum CachePolicy {
  /// Return cached data immediately if present (even if stale), then refresh
  /// silently in the background and update local cache if remote data changed.
  staleWhileRevalidate,

  /// Return valid cached data if present and not expired.
  /// If missing or expired, fetch from network and store in cache.
  cacheFirst,

  /// Always attempt to fetch from network first.
  /// If network call fails, fall back to cached data if available.
  networkFirst,

  /// Return cached data exclusively. Never attempt a network call.
  cacheOnly,

  /// Always fetch fresh data from network. Never read from cache,
  /// but write the fresh result to cache.
  networkOnly,
}
