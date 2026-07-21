import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.type,
    required super.isRead,
    required super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: _asInt(json['id']),
        title: json['title']?.toString().trim() ?? '',
        message: json['message']?.toString().trim() ?? '',
        type: json['type']?.toString().trim() ?? '',
        isRead: _asBool(json['is_read']),
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      );
}

int _asInt(dynamic value) =>
    value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;

bool _asBool(dynamic value) =>
    value == true || value == 1 || value?.toString().toLowerCase() == 'true';
