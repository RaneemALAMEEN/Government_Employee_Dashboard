import 'package:equatable/equatable.dart';

class ProcessDetailsEntity extends Equatable {
  final ProcessInfoEntity process;
  final List<ProcessStageEntity> stages;
  final ProcessValidationEntity validation;

  const ProcessDetailsEntity({
    required this.process,
    required this.stages,
    required this.validation,
  });

  bool get isEmpty => process.id <= 0 && process.name.trim().isEmpty;

  @override
  List<Object?> get props => [process, stages, validation];
}

class ProcessInfoEntity extends Equatable {
  final int id;
  final String name;
  final String code;
  final String status;
  final int version;
  final bool isActive;
  final String approvalStatus;
  final bool isApproved;
  final DateTime? startDate;
  final DateTime? endDate;

  const ProcessInfoEntity({
    required this.id,
    required this.name,
    required this.code,
    required this.status,
    required this.version,
    required this.isActive,
    required this.approvalStatus,
    required this.isApproved,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        code,
        status,
        version,
        isActive,
        approvalStatus,
        isApproved,
        startDate,
        endDate,
      ];
}

class ProcessStageEntity extends Equatable {
  final int id;
  final String name;
  final String code;
  final String type;
  final String authType;
  final bool hasConfig;
  final ProcessStageConfigEntity config;
  final bool hasAssignments;
  final List<ProcessAssignmentEntity> assignments;

  const ProcessStageEntity({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    required this.authType,
    required this.hasConfig,
    required this.config,
    required this.hasAssignments,
    required this.assignments,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        code,
        type,
        authType,
        hasConfig,
        config,
        hasAssignments,
        assignments,
      ];
}

class ProcessStageConfigEntity extends Equatable {
  final String formName;
  final List<ProcessFormWidgetEntity> widgets;
  final List<ProcessTemplateEntity> templates;
  final List<ProcessActionEntity> actions;
  final bool requiresDigitalSignature;
  final Map<String, dynamic> fallback;

  const ProcessStageConfigEntity({
    required this.formName,
    required this.widgets,
    required this.templates,
    required this.actions,
    required this.requiresDigitalSignature,
    this.fallback = const {},
  });

  bool get isEmpty =>
      formName.isEmpty &&
      widgets.isEmpty &&
      templates.isEmpty &&
      actions.isEmpty &&
      !requiresDigitalSignature;

  @override
  List<Object?> get props => [
        formName,
        widgets,
        templates,
        actions,
        requiresDigitalSignature,
        fallback,
      ];
}

class ProcessFormWidgetEntity extends Equatable {
  final String widgetType;
  final ProcessWidgetDataEntity data;

  const ProcessFormWidgetEntity({
    required this.widgetType,
    required this.data,
  });

  @override
  List<Object?> get props => [widgetType, data];
}

class ProcessWidgetDataEntity extends Equatable {
  final String label;
  final bool isRequired;
  final String inputType;
  final int? minLength;
  final int? maxLength;
  final int? minSelections;
  final int? maxSelections;
  final DateTime? minDate;
  final DateTime? maxDate;
  final List<String> allowedExtensions;
  final double? maxSizeMb;
  final bool allowMultiple;
  final List<ProcessOptionEntity> options;
  final Map<String, dynamic> fallback;

  const ProcessWidgetDataEntity({
    required this.label,
    required this.isRequired,
    required this.inputType,
    required this.minLength,
    required this.maxLength,
    required this.minSelections,
    required this.maxSelections,
    required this.minDate,
    required this.maxDate,
    required this.allowedExtensions,
    required this.maxSizeMb,
    required this.allowMultiple,
    required this.options,
    this.fallback = const {},
  });

  @override
  List<Object?> get props => [
        label,
        isRequired,
        inputType,
        minLength,
        maxLength,
        minSelections,
        maxSelections,
        minDate,
        maxDate,
        allowedExtensions,
        maxSizeMb,
        allowMultiple,
        options,
        fallback,
      ];
}

class ProcessOptionEntity extends Equatable {
  final String label;
  final String value;

  const ProcessOptionEntity({required this.label, required this.value});

  String get displayLabel => label.trim().isNotEmpty ? label : value;

  @override
  List<Object?> get props => [label, value];
}

class ProcessTemplateEntity extends Equatable {
  final int templateId;
  final String name;

  const ProcessTemplateEntity({required this.templateId, required this.name});

  @override
  List<Object?> get props => [templateId, name];
}

class ProcessActionEntity extends Equatable {
  final String code;
  final String name;

  const ProcessActionEntity({required this.code, required this.name});

  @override
  List<Object?> get props => [code, name];
}

class ProcessAssignmentEntity extends Equatable {
  final int organizationDepartmentRolesId;
  final ProcessRoleEntity role;

  const ProcessAssignmentEntity({
    required this.organizationDepartmentRolesId,
    required this.role,
  });

  @override
  List<Object?> get props => [organizationDepartmentRolesId, role];
}

class ProcessRoleEntity extends Equatable {
  final int id;
  final String name;
  final bool isActive;
  final ProcessOrganizationEntity organization;
  final ProcessDepartmentEntity department;

  const ProcessRoleEntity({
    required this.id,
    required this.name,
    required this.isActive,
    required this.organization,
    required this.department,
  });

  @override
  List<Object?> get props => [id, name, isActive, organization, department];
}

class ProcessOrganizationEntity extends Equatable {
  final String name;

  const ProcessOrganizationEntity({required this.name});

  @override
  List<Object?> get props => [name];
}

class ProcessDepartmentEntity extends Equatable {
  final String name;

  const ProcessDepartmentEntity({required this.name});

  @override
  List<Object?> get props => [name];
}

class ProcessValidationEntity extends Equatable {
  final bool isValid;
  final List<String> errors;

  const ProcessValidationEntity({
    required this.isValid,
    required this.errors,
  });

  @override
  List<Object?> get props => [isValid, errors];
}
