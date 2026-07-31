import '../../domain/entities/internal_process_entity.dart';

class InternalProcessModel extends InternalProcessEntity {
  const InternalProcessModel({
    required super.processId,
    required super.name,
    required super.code,
    required super.priority,
    super.stageCount,
  });

  factory InternalProcessModel.fromJson(dynamic json) {
    final rawStageCount = json['stages_count'] ??
        json['steps_count'] ??
        json['total_stages'] ??
        json['stage_count'];
    final parsedStageCount = int.tryParse(rawStageCount?.toString() ?? '') ??
        (json['stages'] is List ? (json['stages'] as List).length : null);
    return InternalProcessModel(
      processId: json['process_id'] ?? json['processId'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      priority: json['priority'] ?? 0,
      stageCount: parsedStageCount != null && parsedStageCount > 0
          ? parsedStageCount
          : null,
    );
  }
}
