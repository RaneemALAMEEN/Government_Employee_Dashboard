abstract class OrgHierarchyEvent {
  const OrgHierarchyEvent();
}

class LoadOrgHierarchy extends OrgHierarchyEvent {
  const LoadOrgHierarchy();
}

class SearchOrganizationHierarchy extends OrgHierarchyEvent {
  final String query;

  const SearchOrganizationHierarchy(this.query);
}

class RetryOrganizationSearch extends OrgHierarchyEvent {
  const RetryOrganizationSearch();
}

class ExecuteOrganizationSearch extends OrgHierarchyEvent {
  final String query;
  final int generation;

  const ExecuteOrganizationSearch(this.query, this.generation);
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
