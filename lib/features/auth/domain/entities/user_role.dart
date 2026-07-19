class UserRole {
  final int organizationDepartmentRolesId;
  final int organizationId;
  final int roleId;
  final String roleName;
  final int departmentId;
  final String departmentName;

  UserRole({
    required this.organizationDepartmentRolesId,
    this.organizationId = 0,
    required this.roleId,
    required this.roleName,
    required this.departmentId,
    required this.departmentName,
  });
}
