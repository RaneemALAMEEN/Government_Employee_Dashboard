import '../../domain/entities/process_definitions_response_entity.dart';
import 'process_definition_model.dart';
import 'process_definitions_pagination_model.dart';

class ProcessDefinitionsResponseModel extends ProcessDefinitionsResponseEntity {
  const ProcessDefinitionsResponseModel({
    required super.items,
    required super.pagination,
  });

  factory ProcessDefinitionsResponseModel.fromJson(
    Map<String, dynamic> json, {
    required int requestedPage,
    required int requestedLimit,
  }) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : const <String, dynamic>{};
    final rawItems = data['items'] is List ? data['items'] as List : const [];
    final items = rawItems
        .whereType<Map>()
        .map((item) => ProcessDefinitionModel.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .toList(growable: false);
    final paginationJson = data['pagination'] is Map
        ? Map<String, dynamic>.from(data['pagination'] as Map)
        : const <String, dynamic>{};

    return ProcessDefinitionsResponseModel(
      items: items,
      pagination: ProcessDefinitionsPaginationModel.fromJson(
        paginationJson,
        fallbackPage: requestedPage,
        fallbackLimit: requestedLimit,
        itemCount: items.length,
      ),
    );
  }
}
