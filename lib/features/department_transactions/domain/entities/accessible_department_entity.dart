class AccessibleDepartmentEntity {
  final int id;
  final String name;
  final int organizationId;
  final int? parentId;
  final bool isActive;

  const AccessibleDepartmentEntity({
    required this.id,
    required this.name,
    required this.organizationId,
    this.parentId,
    required this.isActive,
  });
}
