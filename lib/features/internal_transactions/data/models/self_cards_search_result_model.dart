import '../../domain/entities/self_cards_search_result_entity.dart';
import 'self_card_model.dart';

class SelfCardsSearchResultModel extends SelfCardsSearchResultEntity {
  const SelfCardsSearchResultModel({
    required super.items,
    required super.pagination,
  });

  factory SelfCardsSearchResultModel.fromJson(
    Map<String, dynamic> json, {
    required int requestedLimit,
  }) {
    final data = _asMap(json['data']);
    final rawItems = data['items'] is List ? data['items'] as List : const [];
    return SelfCardsSearchResultModel(
      items: rawItems
          .whereType<Map>()
          .map((item) => SelfCardModel.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .where((item) => item.id > 0)
          .toList(growable: false),
      pagination: SelfCardsPaginationModel.fromJson(
        _asMap(data['pagination']),
        requestedLimit: requestedLimit,
      ),
    );
  }
}

class SelfCardsPaginationModel extends SelfCardsPaginationEntity {
  const SelfCardsPaginationModel({
    required super.limit,
    required super.cursor,
    required super.nextCursor,
    required super.hasNext,
    required super.hasPrev,
  });

  factory SelfCardsPaginationModel.fromJson(
    Map<String, dynamic> json, {
    required int requestedLimit,
  }) =>
      SelfCardsPaginationModel(
        limit: _asInt(json['limit']) ?? requestedLimit,
        cursor: _nullableString(json['cursor']),
        nextCursor: _nullableString(json['next_cursor']),
        hasNext: _asBool(json['has_next']),
        hasPrev: _asBool(json['has_prev']),
      );
}

Map<String, dynamic> _asMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

int? _asInt(dynamic value) =>
    value is int ? value : int.tryParse(value?.toString() ?? '');

bool _asBool(dynamic value) =>
    value == true || value == 1 || value?.toString().toLowerCase() == 'true';

String? _nullableString(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}
