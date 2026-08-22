import '../../domain/entities/dynamic_form_entity.dart';
import 'dynamic_widget_model.dart';

class DynamicFormModel extends DynamicFormEntity {
  const DynamicFormModel({
    required super.transactionId,
    required super.formId,
    required super.formName,
    required super.note,
    required super.decision,
    required super.requiresDigitalSignature,
    super.isAssignment,
    required super.widgets,
    super.expectedVersion,
    super.templateIds,
    super.templates,
    super.processName,
    super.currentStageNumber,
    super.totalStages,
  });

  factory DynamicFormModel.fromJson(Map<String, dynamic> json) {
    final config = json['config_json'] as Map<String, dynamic>? ?? json;
    final widgetsJson = config['widgets'] as List? ?? [];

    final rawIsAssignment = json['is_assignment'] ??
        json['has_assignments'] ??
        config['is_assignment'] ??
        config['has_assignments'] ??
        (json['stage'] is Map
            ? (json['stage'] as Map)['is_assignment'] ??
                (json['stage'] as Map)['has_assignments']
            : null) ??
        (json['current_stage'] is Map
            ? (json['current_stage'] as Map)['is_assignment'] ??
                (json['current_stage'] as Map)['has_assignments']
            : null);

    final isAssignment = rawIsAssignment == true ||
        rawIsAssignment == 1 ||
        rawIsAssignment == '1' ||
        rawIsAssignment == 'true' ||
        rawIsAssignment == 'TRUE' ||
        (json['assignments'] is List && (json['assignments'] as List).isNotEmpty) ||
        (config['assignments'] is List && (config['assignments'] as List).isNotEmpty);

    final templateJson =
        config['template'] as List? ?? config['templates'] as List? ?? [];
    final inlineTemplatesJson = templateJson
        .whereType<Map<String, dynamic>>()
        .where((item) => item['widgets'] is List)
        .toList();
    final stages = json['stages'] is List
        ? json['stages'] as List
        : config['stages'] is List
            ? config['stages'] as List
            : null;
    final rawTotalStages = json['stages_count'] ??
        json['steps_count'] ??
        json['total_stages'] ??
        config['stages_count'] ??
        config['steps_count'] ??
        config['total_stages'];
    final parsedTotalStages =
        int.tryParse(rawTotalStages?.toString() ?? '') ?? stages?.length;
    final rawCurrentStage = json['stage_number'] ??
        json['current_stage_number'] ??
        json['stage_order'] ??
        config['stage_number'] ??
        config['current_stage_number'] ??
        config['stage_order'];
    final parsedCurrentStage = int.tryParse(rawCurrentStage?.toString() ?? '');

    return DynamicFormModel(
      transactionId: json['transaction_id'] ?? 0,
      formId: config['form_id']?.toString() ?? '',
      formName: config['form_name']?.toString() ?? '',
      note: config['note']?.toString() ?? '',
      decision: config['decision']?.toString() ?? '',
      expectedVersion:
          int.tryParse(config['expected_version']?.toString() ?? ''),
      requiresDigitalSignature: config['requires_digital_signature'] == true,
      isAssignment: isAssignment,
      widgets: widgetsJson
          .map(
            (item) => DynamicWidgetModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      templateIds: templateJson
          .map((item) {
            if (item is Map<String, dynamic>) {
              return item['template_id'] ?? item['id'];
            }
            return item;
          })
          .where((id) => id != null)
          .map((id) => int.tryParse(id.toString()) ?? 0)
          .where((id) => id > 0)
          .toList(),
      templates: inlineTemplatesJson
          .map(
            (item) => DynamicFormTemplateEntity(
              id: int.tryParse(item['id']?.toString() ?? '') ?? 0,
              config: DynamicFormModel.fromJson(item),
            ),
          )
          .toList(),
      processName: (json['process_name'] ?? config['process_name'])?.toString(),
      currentStageNumber: parsedCurrentStage != null && parsedCurrentStage > 0
          ? parsedCurrentStage
          : null,
      totalStages: parsedTotalStages != null && parsedTotalStages > 0
          ? parsedTotalStages
          : null,
    );
  }
}
