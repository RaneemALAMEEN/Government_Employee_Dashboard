class OrganizationSearchEntity {
  final int organizationId;
  final String scope;
  final String query;
  final List<OrganizationSearchDepartmentEntity> departments;
  final List<OrganizationSearchRoleEntity> roles;
  final List<OrganizationSearchEmployeeEntity> employees;
  final OrganizationSearchPaginationEntity pagination;

  const OrganizationSearchEntity({
    required this.organizationId,
    required this.scope,
    required this.query,
    required this.departments,
    required this.roles,
    required this.employees,
    required this.pagination,
  });

  bool get isEmpty => departments.isEmpty && roles.isEmpty && employees.isEmpty;
}

class OrganizationSearchDepartmentEntity {
  final int id;
  final String name;

  const OrganizationSearchDepartmentEntity({
    required this.id,
    required this.name,
  });
}

class OrganizationSearchRoleEntity {
  final int id;
  final String name;
  final String code;
  final int? departmentId;
  final String? departmentName;

  const OrganizationSearchRoleEntity({
    required this.id,
    required this.name,
    required this.code,
    this.departmentId,
    this.departmentName,
  });
}

class OrganizationSearchEmployeeEntity {
  final int id;
  final String userName;
  final String email;
  final String firstName;
  final String lastName;
  final String fatherName;
  final String motherName;
  final String nationalId;
  final bool isActive;
  final List<OrganizationSearchAssignmentEntity> assignments;

  const OrganizationSearchEmployeeEntity({
    required this.id,
    required this.userName,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fatherName,
    required this.motherName,
    required this.nationalId,
    required this.isActive,
    required this.assignments,
  });

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? userName : name;
  }
}

class OrganizationSearchAssignmentEntity {
  final int assignmentId;
  final int odrId;
  final int roleId;
  final String roleName;
  final String roleCode;
  final int departmentId;
  final String departmentName;

  const OrganizationSearchAssignmentEntity({
    required this.assignmentId,
    required this.odrId,
    required this.roleId,
    required this.roleName,
    required this.roleCode,
    required this.departmentId,
    required this.departmentName,
  });
}

class OrganizationSearchPaginationEntity {
  final int limit;
  final bool departmentsHasNext;
  final bool rolesHasNext;
  final bool employeesHasNext;

  const OrganizationSearchPaginationEntity({
    required this.limit,
    required this.departmentsHasNext,
    required this.rolesHasNext,
    required this.employeesHasNext,
  });
}
