import '../../domain/entities/notifications_response_entity.dart';
import 'notification_model.dart';
import 'notifications_pagination_model.dart';

class NotificationsResponseModel extends NotificationsResponseEntity {
  const NotificationsResponseModel({
    required super.items,
    required super.pagination,
    required super.unreadCount,
  });

  factory NotificationsResponseModel.fromJson(
    Map<String, dynamic> json, {
    required int requestedLimit,
  }) {
    final data = _map(json['data']);
    final rawItems = data['items'] is List ? data['items'] as List : const [];
    return NotificationsResponseModel(
      items: rawItems
          .whereType<Map>()
          .map((item) => NotificationModel.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList(growable: false),
      pagination: NotificationsPaginationModel.fromJson(
        _map(data['pagination']),
        requestedLimit: requestedLimit,
      ),
      unreadCount: _asInt(data['unread_count']),
    );
  }
}

Map<String, dynamic> _map(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

int _asInt(dynamic value) =>
    value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;
