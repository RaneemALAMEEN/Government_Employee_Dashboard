/// Represents the freshness status of retrieved data.
/// Used by presentation/repository layers to make UI or caching decisions.
enum DataFreshnessStatus {
  /// Data was just retrieved fresh from the remote backend.
  fresh,

  /// Data was retrieved from local cache and is within its valid TTL window.
  cached,

  /// Data was retrieved from local cache but has passed its TTL duration.
  /// Ideal for SWR (Stale-While-Revalidate) workflows.
  stale,

  /// Data was retrieved from local cache because the device is offline or the
  /// remote server is unreachable.
  offline,
}
