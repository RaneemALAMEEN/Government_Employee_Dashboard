import '../../domain/entities/process_definitions_pagination_entity.dart';

class ProcessDefinitionsPaginationModel
    extends ProcessDefinitionsPaginationEntity {
  const ProcessDefinitionsPaginationModel({
    required super.page,
    required super.limit,
    required super.total,
    required super.totalPages,
    required super.hasNext,
    required super.hasPrev,
  });

  factory ProcessDefinitionsPaginationModel.fromJson(
    Map<String, dynamic> json, {
    required int fallbackPage,
    required int fallbackLimit,
    required int itemCount,
  }) {
    final page = _asInt(json['page'], fallbackPage);
    final limit = _asInt(json['limit'], fallbackLimit);
    return ProcessDefinitionsPaginationModel(
      page: page,
      limit: limit,
      total: _asInt(json['total'], itemCount),
      totalPages: _asInt(json['total_pages'], page),
      hasNext: _asNullableBool(json['has_next']) ?? itemCount == limit,
      hasPrev: _asNullableBool(json['has_prev']) ?? page > 1,
    );
  }

  static int _asInt(dynamic value, int fallback) =>
      value is int ? value : int.tryParse(value?.toString() ?? '') ?? fallback;

  static bool? _asNullableBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value == null) return null;
    if (value.toString().toLowerCase() == 'true') return true;
    if (value.toString().toLowerCase() == 'false') return false;
    return null;
  }
}
