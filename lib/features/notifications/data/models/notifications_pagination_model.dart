import '../../domain/entities/notifications_pagination_entity.dart';

class NotificationsPaginationModel extends NotificationsPaginationEntity {
  const NotificationsPaginationModel({
    required super.limit,
    required super.cursor,
    required super.nextCursor,
    required super.hasNext,
    required super.hasPrev,
  });

  factory NotificationsPaginationModel.fromJson(
    Map<String, dynamic> json, {
    required int requestedLimit,
  }) =>
      NotificationsPaginationModel(
        limit: _asInt(json['limit'], fallback: requestedLimit),
        cursor: _nullableString(json['cursor']),
        nextCursor: _nullableString(json['next_cursor']),
        hasNext: _asBool(json['has_next']),
        hasPrev: _asBool(json['has_prev']),
      );
}

int _asInt(dynamic value, {required int fallback}) =>
    value is int ? value : int.tryParse(value?.toString() ?? '') ?? fallback;

bool _asBool(dynamic value) =>
    value == true || value == 1 || value?.toString().toLowerCase() == 'true';

String? _nullableString(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}
