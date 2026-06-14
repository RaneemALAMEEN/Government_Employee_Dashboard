import '../../domain/entities/internal_process_entity.dart';

class InternalProcessModel extends InternalProcessEntity {
  const InternalProcessModel({
    required super.processId,
    required super.name,
    required super.code,
    required super.priority,
  });

  factory InternalProcessModel.fromJson(dynamic json) {
    return InternalProcessModel(
      processId: json['process_id'] ?? json['processId'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      priority: json['priority'] ?? 0,
    );
  }
}