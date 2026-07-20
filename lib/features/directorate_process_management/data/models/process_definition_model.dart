import '../../domain/entities/process_definition_entity.dart';

class ProcessDefinitionModel extends ProcessDefinitionEntity {
  final Map<String, dynamic>? debugRawJson;

  const ProcessDefinitionModel({
    required super.processId,
    required super.name,
    required super.code,
    required super.priority,
    required super.deploymentStatus,
    required super.approvalStatus,
    required super.isActive,
    this.debugRawJson,
  });

  factory ProcessDefinitionModel.fromJson(Map<String, dynamic> json) {
    return ProcessDefinitionModel(
      processId: _asInt(json['process_id']),
      name: _asString(json['name'], fallback: 'قالب معاملة'),
      code: _asString(json['code'], fallback: '—'),
      priority: _asInt(json['priority']),
      deploymentStatus:
          _asString(json['deployment_status'], fallback: 'unknown'),
      approvalStatus: _asString(json['approval_status'], fallback: 'UNKNOWN'),
      isActive: _asBool(json['is_active']),
      debugRawJson: Map.unmodifiable(json),
    );
  }

  static int _asInt(dynamic value) =>
      value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;

  static String _asString(dynamic value, {required String fallback}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  static bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    return value?.toString().toLowerCase() == 'true';
  }
}
