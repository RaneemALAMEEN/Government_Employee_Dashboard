import '../services/websocket_cache_sync_bus.dart';

/// Mixin for repositories or local data sources enabling direct, real-time
/// cache updates driven by incoming WebSocket push events.
mixin WebSocketCacheSyncMixin {
  /// Reference to core [WebSocketCacheSyncBus].
  WebSocketCacheSyncBus get webSocketCacheSyncBus;

  /// Registers a targeted listener for creation events.
  void onWebSocketItemCreated<T>({
    required String entityType,
    required Future<void> Function(Map<String, dynamic> payload) onInsert,
  }) {
    webSocketCacheSyncBus.registerCreateHandler(
      entityType: entityType,
      handler: onInsert,
    );
  }

  /// Registers a targeted listener for update events.
  void onWebSocketItemUpdated<T>({
    required String entityType,
    required Future<void> Function(Map<String, dynamic> payload) onUpdate,
  }) {
    webSocketCacheSyncBus.registerUpdateHandler(
      entityType: entityType,
      handler: onUpdate,
    );
  }

  /// Registers a targeted listener for deletion events.
  void onWebSocketItemDeleted<T>({
    required String entityType,
    required Future<void> Function(Map<String, dynamic> payload) onDelete,
  }) {
    webSocketCacheSyncBus.registerDeleteHandler(
      entityType: entityType,
      handler: onDelete,
    );
  }
}
