abstract class OrgHierarchyEvent {
  const OrgHierarchyEvent();
}

class LoadOrgHierarchy extends OrgHierarchyEvent {
  const LoadOrgHierarchy();
}

class LoadDepartmentRoles extends OrgHierarchyEvent {
  final int departmentId;

  const LoadDepartmentRoles(this.departmentId);
}

class LoadRoleEmployees extends OrgHierarchyEvent {
  final int departmentId;
  final int roleId;

  const LoadRoleEmployees({required this.departmentId, required this.roleId});
}
