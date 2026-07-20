class StatisticsEmployeeDetailsEntity {
  final int id;
  final String userName;
  final String email;
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String fatherName;
  final String motherName;
  final String nationalId;
  final bool isActive;
  final EmployeeOrganizationEntity organization;
  final EmployeeDepartmentEntity department;
  final EmployeeRoleEntity role;
  final int organizationDepartmentRolesId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StatisticsEmployeeDetailsEntity({
    required this.id,
    required this.userName,
    required this.email,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.fatherName,
    required this.motherName,
    required this.nationalId,
    required this.isActive,
    required this.organization,
    required this.department,
    required this.role,
    required this.organizationDepartmentRolesId,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName'.trim();
}

class EmployeeOrganizationEntity {
  final int id;
  final String name;

  const EmployeeOrganizationEntity({required this.id, required this.name});
}

class EmployeeDepartmentEntity {
  final int id;
  final String name;

  const EmployeeDepartmentEntity({required this.id, required this.name});
}

class EmployeeRoleEntity {
  final int id;
  final String name;
  final String code;

  const EmployeeRoleEntity({
    required this.id,
    required this.name,
    required this.code,
  });
}
