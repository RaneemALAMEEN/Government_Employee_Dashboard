import '../../domain/entities/statistics_pagination_entity.dart';

class StatisticsPaginationModel extends StatisticsPaginationEntity {
  const StatisticsPaginationModel({
    required super.limit,
    required super.cursor,
    required super.nextCursor,
    required super.hasNext,
    required super.hasPrev,
  });

  factory StatisticsPaginationModel.fromJson(
    Map<String, dynamic> json, {
    required int requestedLimit,
  }) =>
      StatisticsPaginationModel(
        limit: _asInt(json['limit']) ?? requestedLimit,
        cursor: _asNullableString(json['cursor']),
        nextCursor: _asNullableString(json['next_cursor']),
        hasNext: _asBool(json['has_next']),
        hasPrev: _asBool(json['has_prev']),
      );
}

int? _asInt(dynamic value) =>
    value is int ? value : int.tryParse(value?.toString() ?? '');

bool _asBool(dynamic value) =>
    value == true || value == 1 || value?.toString().toLowerCase() == 'true';

String? _asNullableString(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}
