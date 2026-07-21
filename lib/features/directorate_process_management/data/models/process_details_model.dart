import 'dart:convert';

import '../../domain/entities/process_details_entity.dart';

class ProcessDetailsModel extends ProcessDetailsEntity {
  const ProcessDetailsModel({
    required super.process,
    required super.stages,
    required super.validation,
  });

  factory ProcessDetailsModel.fromJson(Map<String, dynamic> json) {
    final root = _map(json['data']);
    final stagesJson = _list(root['stages']);
    return ProcessDetailsModel(
      process: ProcessInfoModel.fromJson(_map(root['process'])),
      stages: stagesJson
          .map((item) => ProcessStageModel.fromJson(_map(item)))
          .toList(growable: false),
      validation: ProcessValidationModel.fromJson(_map(root['validation'])),
    );
  }
}

class ProcessInfoModel extends ProcessInfoEntity {
  const ProcessInfoModel({
    required super.id,
    required super.name,
    required super.code,
    required super.status,
    required super.version,
    required super.isActive,
    required super.approvalStatus,
    required super.isApproved,
    required super.startDate,
    required super.endDate,
  });

  factory ProcessInfoModel.fromJson(Map<String, dynamic> json) =>
      ProcessInfoModel(
        id: _int(json['id']),
        name: _string(json['name']),
        code: _string(json['code']),
        status: _string(json['status']),
        version: _int(json['version']),
        isActive: _bool(json['is_active']),
        approvalStatus: _string(json['approval_status']),
        isApproved: _bool(json['is_approved']),
        startDate: _date(json['start_date']),
        endDate: _date(json['end_date']),
      );
}

class ProcessStageModel extends ProcessStageEntity {
  const ProcessStageModel({
    required super.id,
    required super.name,
    required super.code,
    required super.type,
    required super.authType,
    required super.hasConfig,
    required super.config,
    required super.hasAssignments,
    required super.assignments,
  });

  factory ProcessStageModel.fromJson(Map<String, dynamic> json) {
    final assignmentsJson = _list(json['assignments']);
    final configJson = _map(json['config']);
    for (final key in const [
      'widgets',
      'form',
      'form_name',
      'template',
      'templates',
      'action',
      'actions',
      'requires_digital_signature',
      'requiresDigitalSignature',
      'digital_signature_required',
    ]) {
      if (!configJson.containsKey(key) && json.containsKey(key)) {
        configJson[key] = json[key];
      }
    }
    return ProcessStageModel(
      id: _int(json['id']),
      name: _string(json['name']),
      code: _string(json['code']),
      type: _string(json['type']),
      authType: _string(json['auth_type']),
      hasConfig: _bool(json['has_config']),
      config: ProcessStageConfigModel.fromJson(configJson),
      hasAssignments: _bool(json['has_assignments']),
      assignments: assignmentsJson
          .map((item) => ProcessAssignmentModel.fromJson(_map(item)))
          .toList(growable: false),
    );
  }
}

class ProcessStageConfigModel extends ProcessStageConfigEntity {
  const ProcessStageConfigModel({
    required super.formName,
    required super.widgets,
    required super.templates,
    required super.actions,
    required super.requiresDigitalSignature,
    required super.fallback,
  });

  factory ProcessStageConfigModel.fromJson(Map<String, dynamic> json) {
    final form = _map(json['form']);
    final widgetsSource = json['widgets'] ?? form['widgets'];
    return ProcessStageConfigModel(
      formName: _string(json['form_name'] ?? form['name']),
      widgets: _list(widgetsSource)
          .map((item) => ProcessFormWidgetModel.fromJson(_map(item)))
          .toList(growable: false),
      templates: _objects(json['templates'] ?? json['template'])
          .map((item) => ProcessTemplateModel.fromDynamic(item))
          .toList(growable: false),
      actions: _objects(json['actions'] ?? json['action'])
          .map((item) => ProcessActionModel.fromDynamic(item))
          .toList(growable: false),
      requiresDigitalSignature: _bool(
        json['requires_digital_signature'] ??
            json['requiresDigitalSignature'] ??
            json['digital_signature_required'],
      ),
      fallback: json,
    );
  }
}

class ProcessFormWidgetModel extends ProcessFormWidgetEntity {
  const ProcessFormWidgetModel({
    required super.widgetType,
    required super.data,
  });

  factory ProcessFormWidgetModel.fromJson(Map<String, dynamic> json) =>
      ProcessFormWidgetModel(
        widgetType: _string(json['widget_type'] ?? json['type']),
        data: ProcessWidgetDataModel.fromJson(_map(json['data'])),
      );
}

class ProcessWidgetDataModel extends ProcessWidgetDataEntity {
  const ProcessWidgetDataModel({
    required super.label,
    required super.isRequired,
    required super.inputType,
    required super.minLength,
    required super.maxLength,
    required super.minSelections,
    required super.maxSelections,
    required super.minDate,
    required super.maxDate,
    required super.allowedExtensions,
    required super.maxSizeMb,
    required super.allowMultiple,
    required super.options,
    required super.fallback,
  });

  factory ProcessWidgetDataModel.fromJson(Map<String, dynamic> json) {
    final extensionSource = json['allowed_extensions'] ??
        json['allowed_types'] ??
        json['allowed_file_types'] ??
        json['file_types'];
    return ProcessWidgetDataModel(
      label: _string(json['label'] ?? json['name'] ?? json['title']),
      isRequired: _bool(json['is_required'] ?? json['required']),
      inputType: _string(json['input_type']),
      minLength: _nullableInt(json['min_length']),
      maxLength: _nullableInt(json['max_length']),
      minSelections: _nullableInt(json['min_selections'] ??
          json['min_selection'] ??
          json['min_selected']),
      maxSelections: _nullableInt(json['max_selections'] ??
          json['max_selection'] ??
          json['max_selected']),
      minDate: _date(json['min_date'] ?? json['start_date']),
      maxDate: _date(json['max_date'] ?? json['end_date']),
      allowedExtensions: _strings(extensionSource),
      maxSizeMb: _nullableDouble(
        json['max_size_mb'] ?? json['max_file_size_mb'] ?? json['max_size'],
      ),
      allowMultiple: _bool(
        json['allow_multiple'] ?? json['multiple'] ?? json['is_multiple'],
      ),
      options: _list(json['options'])
          .map((item) => ProcessOptionModel.fromDynamic(item))
          .toList(growable: false),
      fallback: json,
    );
  }
}

class ProcessOptionModel extends ProcessOptionEntity {
  const ProcessOptionModel({required super.label, required super.value});

  factory ProcessOptionModel.fromDynamic(dynamic item) {
    if (item is Map) {
      final json = Map<String, dynamic>.from(item);
      return ProcessOptionModel(
        label: _string(json['label'] ?? json['name']),
        value: _string(json['value'] ?? json['id']),
      );
    }
    final value = _string(item);
    return ProcessOptionModel(label: value, value: value);
  }
}

class ProcessTemplateModel extends ProcessTemplateEntity {
  const ProcessTemplateModel({required super.templateId, required super.name});

  factory ProcessTemplateModel.fromDynamic(dynamic item) {
    if (item is Map) {
      final json = Map<String, dynamic>.from(item);
      return ProcessTemplateModel(
        templateId: _int(json['template_id'] ?? json['id']),
        name: _string(json['name'] ?? json['template_name']),
      );
    }
    return ProcessTemplateModel(templateId: _int(item), name: '');
  }
}

class ProcessActionModel extends ProcessActionEntity {
  const ProcessActionModel({required super.code, required super.name});

  factory ProcessActionModel.fromDynamic(dynamic item) {
    if (item is Map) {
      final json = Map<String, dynamic>.from(item);
      return ProcessActionModel(
        code: _string(json['code'] ?? json['action'] ?? json['type']),
        name: _string(json['name'] ?? json['label']),
      );
    }
    return ProcessActionModel(code: _string(item), name: '');
  }
}

class ProcessAssignmentModel extends ProcessAssignmentEntity {
  const ProcessAssignmentModel({
    required super.organizationDepartmentRolesId,
    required super.role,
  });

  factory ProcessAssignmentModel.fromJson(Map<String, dynamic> json) =>
      ProcessAssignmentModel(
        organizationDepartmentRolesId:
            _int(json['organization_department_roles_id']),
        role: ProcessRoleModel.fromJson(_map(json['role'])),
      );
}

class ProcessRoleModel extends ProcessRoleEntity {
  const ProcessRoleModel({
    required super.id,
    required super.name,
    required super.isActive,
    required super.organization,
    required super.department,
  });

  factory ProcessRoleModel.fromJson(Map<String, dynamic> json) =>
      ProcessRoleModel(
        id: _int(json['id']),
        name: _string(json['name']),
        isActive: _bool(json['is_active']),
        organization:
            ProcessOrganizationModel.fromJson(_map(json['organization'])),
        department: ProcessDepartmentModel.fromJson(_map(json['department'])),
      );
}

class ProcessOrganizationModel extends ProcessOrganizationEntity {
  const ProcessOrganizationModel({required super.name});

  factory ProcessOrganizationModel.fromJson(Map<String, dynamic> json) =>
      ProcessOrganizationModel(name: _string(json['name']));
}

class ProcessDepartmentModel extends ProcessDepartmentEntity {
  const ProcessDepartmentModel({required super.name});

  factory ProcessDepartmentModel.fromJson(Map<String, dynamic> json) =>
      ProcessDepartmentModel(name: _string(json['name']));
}

class ProcessValidationModel extends ProcessValidationEntity {
  const ProcessValidationModel({
    required super.isValid,
    required super.errors,
  });

  factory ProcessValidationModel.fromJson(Map<String, dynamic> json) =>
      ProcessValidationModel(
        isValid: _bool(json['is_valid']),
        errors: _list(json['errors'])
            .map((error) {
              if (error is String) return error;
              if (error is Map) {
                final map = Map<String, dynamic>.from(error);
                return _string(
                  map['message'] ?? map['error'] ?? map['detail'],
                ).isNotEmpty
                    ? _string(map['message'] ?? map['error'] ?? map['detail'])
                    : jsonEncode(map);
              }
              return error?.toString() ?? '';
            })
            .where((error) => error.isNotEmpty)
            .toList(growable: false),
      );
}

Map<String, dynamic> _map(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

List<dynamic> _list(dynamic value) => value is List ? value : const [];

List<dynamic> _objects(dynamic value) {
  if (value == null) return const [];
  return value is List ? value : [value];
}

List<String> _strings(dynamic value) {
  if (value is List) {
    return value.map(_string).where((item) => item.isNotEmpty).toList();
  }
  final text = _string(value);
  if (text.isEmpty) return const [];
  return text
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

String _string(dynamic value) => value?.toString().trim() ?? '';

int _int(dynamic value) =>
    value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;

int? _nullableInt(dynamic value) {
  if (value == null || value.toString().trim().isEmpty) return null;
  return value is int ? value : int.tryParse(value.toString());
}

double? _nullableDouble(dynamic value) {
  if (value == null || value.toString().trim().isEmpty) return null;
  return value is num ? value.toDouble() : double.tryParse(value.toString());
}

bool _bool(dynamic value) =>
    value == true || value == 1 || value?.toString().toLowerCase() == 'true';

DateTime? _date(dynamic value) {
  final text = _string(value);
  return text.isEmpty ? null : DateTime.tryParse(text);
}
