class DepartmentRoleEntity {
  final int id;
  final int organizationDepartmentRolesId;
  final String name;
  final String code;

  const DepartmentRoleEntity({
    required this.id,
    required this.organizationDepartmentRolesId,
    required this.name,
    required this.code,
  });
}
