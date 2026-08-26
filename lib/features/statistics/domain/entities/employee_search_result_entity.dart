import 'package:equatable/equatable.dart';

import 'statistics_employee_details_entity.dart';

class EmployeeSearchResultEntity extends Equatable {
  final List<EmployeeSearchItemEntity> items;
  final EmployeeSearchPaginationEntity pagination;

  const EmployeeSearchResultEntity({
    required this.items,
    required this.pagination,
  });

  @override
  List<Object?> get props => [items, pagination];
}

class EmployeeSearchItemEntity extends Equatable {
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

  const EmployeeSearchItemEntity({
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
    this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get displayName {
    if (fatherName.isNotEmpty) {
      return '$firstName $fatherName $lastName'.trim();
    }
    return fullName;
  }

  String get departmentName => department.name;
  String get roleName => role.name;
  String get organizationName => organization.name;

  @override
  List<Object?> get props => [
        id,
        userName,
        email,
        phoneNumber,
        firstName,
        lastName,
        fatherName,
        motherName,
        nationalId,
        isActive,
        organization,
        department,
        role,
        organizationDepartmentRolesId,
        createdAt,
        updatedAt,
      ];
}

class EmployeeSearchPaginationEntity extends Equatable {
  final int limit;
  final String? cursor;
  final String? nextCursor;
  final bool hasNext;
  final bool hasPrev;

  const EmployeeSearchPaginationEntity({
    required this.limit,
    this.cursor,
    this.nextCursor,
    required this.hasNext,
    required this.hasPrev,
  });

  @override
  List<Object?> get props => [limit, cursor, nextCursor, hasNext, hasPrev];
}
