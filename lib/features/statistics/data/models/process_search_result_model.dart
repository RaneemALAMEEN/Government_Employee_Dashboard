import '../../domain/entities/process_search_result_entity.dart';

class ProcessSearchResultModel extends ProcessSearchResultEntity {
  const ProcessSearchResultModel({
    required super.items,
    required super.pagination,
  });

  factory ProcessSearchResultModel.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']);
    final itemsList = data['items'] as List? ?? [];
    final paginationMap = _asMap(data['pagination']);

    return ProcessSearchResultModel(
      items: itemsList
          .whereType<Map>()
          .map(
            (item) => ProcessSearchItemModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      pagination: ProcessSearchPaginationModel.fromJson(paginationMap),
    );
  }
}

class ProcessSearchItemModel extends ProcessSearchItemEntity {
  const ProcessSearchItemModel({
    required super.id,
    required super.name,
    required super.code,
    super.camundaProcessKey,
    required super.priority,
    required super.isActive,
    required super.approvalStatus,
    required super.isComplaint,
    super.typeTransId,
    required super.typeTransName,
    required super.organizationId,
    required super.organizationName,
    super.createdAt,
    super.updatedAt,
  });

  factory ProcessSearchItemModel.fromJson(Map<String, dynamic> json) {
    return ProcessSearchItemModel(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      code: _asString(json['code']),
      camundaProcessKey: json['camunda_process_key']?.toString(),
      priority: _asInt(json['priority']),
      isActive: _asBool(json['is_active']),
      approvalStatus: _asString(json['approval_status']),
      isComplaint: _asBool(json['is_complaint'] ?? json['is_complete']),
      typeTransId:
          json['type_trans_id'] != null ? _asInt(json['type_trans_id']) : null,
      typeTransName: _asString(json['type_trans_name']),
      organizationId: _asInt(json['organization_id']),
      organizationName: _asString(json['organization_name']),
      createdAt: _asDateTime(json['created_at']),
      updatedAt: _asDateTime(json['updated_at']),
    );
  }
}

class ProcessSearchPaginationModel extends ProcessSearchPaginationEntity {
  const ProcessSearchPaginationModel({
    required super.limit,
    super.cursor,
    super.nextCursor,
    required super.hasNext,
    required super.hasPrev,
  });

  factory ProcessSearchPaginationModel.fromJson(Map<String, dynamic> json) {
    return ProcessSearchPaginationModel(
      limit: _asInt(json['limit']) == 0 ? 6 : _asInt(json['limit']),
      cursor: json['cursor']?.toString(),
      nextCursor: json['next_cursor']?.toString(),
      hasNext: _asBool(json['has_next']),
      hasPrev: _asBool(json['has_prev']),
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

int _asInt(dynamic value) =>
    value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;

String _asString(dynamic value) => value?.toString().trim() ?? '';

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return value?.toString().toLowerCase() == 'true';
}

DateTime? _asDateTime(dynamic value) =>
    DateTime.tryParse(value?.toString() ?? '');
