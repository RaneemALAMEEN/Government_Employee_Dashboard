import 'package:flutter/foundation.dart';
import 'cache_manager.dart';

typedef WebSocketEventHandler = Future<void> Function(
  Map<String, dynamic> payload,
);

/// Event bus orchestrating real-time, targeted cache mutations driven by
/// WebSocket push notifications.
///
/// Prevents full page reloads when single items are created, updated, or deleted.
class WebSocketCacheSyncBus {
  final CacheManager cacheManager;

  final Map<String, List<WebSocketEventHandler>> _createHandlers = {};
  final Map<String, List<WebSocketEventHandler>> _updateHandlers = {};
  final Map<String, List<WebSocketEventHandler>> _deleteHandlers = {};

  WebSocketCacheSyncBus({required this.cacheManager});

  /// Registers a handler for entity creation events.
  void registerCreateHandler({
    required String entityType,
    required WebSocketEventHandler handler,
  }) {
    _createHandlers.putIfAbsent(entityType, () => []).add(handler);
  }

  /// Registers a handler for entity update events.
  void registerUpdateHandler({
    required String entityType,
    required WebSocketEventHandler handler,
  }) {
    _updateHandlers.putIfAbsent(entityType, () => []).add(handler);
  }

  /// Registers a handler for entity deletion events.
  void registerDeleteHandler({
    required String entityType,
    required WebSocketEventHandler handler,
  }) {
    _deleteHandlers.putIfAbsent(entityType, () => []).add(handler);
  }

  /// Dispatches an incoming WebSocket event to registered handlers.
  Future<void> dispatchEvent({
    required String action, // 'create', 'update', 'delete'
    required String entityType,
    required Map<String, dynamic> payload,
  }) async {
    debugPrint(
      '[WebSocketCacheSyncBus] Dispatching event: action=$action, entity=$entityType',
    );

    List<WebSocketEventHandler>? handlers;
    switch (action.toLowerCase()) {
      case 'create':
        handlers = _createHandlers[entityType];
        break;
      case 'update':
        handlers = _updateHandlers[entityType];
        break;
      case 'delete':
        handlers = _deleteHandlers[entityType];
        break;
    }

    if (handlers != null && handlers.isNotEmpty) {
      for (final handler in handlers) {
        try {
          await handler(payload);
        } catch (e) {
          debugPrint(
            '[WebSocketCacheSyncBus] Error executing handler for $entityType ($action): $e',
          );
        }
      }
    }
  }
}
