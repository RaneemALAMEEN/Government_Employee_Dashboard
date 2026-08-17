import '../../domain/entities/accessible_department_entity.dart';

class AccessibleDepartmentModel extends AccessibleDepartmentEntity {
  const AccessibleDepartmentModel({
    required super.id,
    required super.name,
    required super.organizationId,
    super.parentId,
    required super.isActive,
  });

  factory AccessibleDepartmentModel.fromJson(Map<String, dynamic> json) {
    return AccessibleDepartmentModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      organizationId: json['organization_id'] as int? ?? 0,
      parentId: json['parent_id'] as int?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
