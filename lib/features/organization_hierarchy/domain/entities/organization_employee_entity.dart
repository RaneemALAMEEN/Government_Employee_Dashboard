class OrganizationEmployeeEntity {
  final int assignmentId;
  final int organizationDepartmentRolesId;
  final int priority;
  final bool isActive;
  final int userId;
  final String userName;
  final String email;
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String fatherName;
  final String motherName;
  final String nationalId;
  final bool userIsActive;

  const OrganizationEmployeeEntity({
    required this.assignmentId,
    required this.organizationDepartmentRolesId,
    required this.priority,
    required this.isActive,
    required this.userId,
    required this.userName,
    required this.email,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.fatherName,
    required this.motherName,
    required this.nationalId,
    required this.userIsActive,
  });

  String get fullName {
    final value = '$firstName $lastName'.trim();
    return value.isEmpty ? userName : value;
  }
}
