import '../../domain/entities/organization_search_entity.dart';

class OrganizationSearchResponseModel extends OrganizationSearchEntity {
  const OrganizationSearchResponseModel({
    required super.organizationId,
    required super.scope,
    required super.query,
    required super.departments,
    required super.roles,
    required super.employees,
    required super.pagination,
  });

  factory OrganizationSearchResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    return OrganizationSearchResponseModel(
      organizationId: _asInt(data['organization_id']),
      scope: _asText(data['scope']),
      query: _asText(data['q']),
      departments: _maps(data['departments'])
          .map(DepartmentSearchResultModel.fromJson)
          .where((item) => item.id > 0 && item.name.isNotEmpty)
          .toList(growable: false),
      roles: _maps(data['roles'])
          .map(RoleSearchResultModel.fromJson)
          .where((item) => item.id > 0 && item.name.isNotEmpty)
          .toList(growable: false),
      employees: _maps(data['employees'])
          .map(EmployeeSearchResultModel.fromJson)
          .where((item) => item.id > 0)
          .toList(growable: false),
      pagination: OrganizationSearchPaginationModel.fromJson(
        data['pagination'] is Map
            ? Map<String, dynamic>.from(data['pagination'] as Map)
            : const {},
      ),
    );
  }
}

class DepartmentSearchResultModel extends OrganizationSearchDepartmentEntity {
  const DepartmentSearchResultModel({required super.id, required super.name});

  factory DepartmentSearchResultModel.fromJson(Map<String, dynamic> json) =>
      DepartmentSearchResultModel(
        id: _asInt(json['id']),
        name: _asText(json['name']),
      );
}

class RoleSearchResultModel extends OrganizationSearchRoleEntity {
  const RoleSearchResultModel({
    required super.id,
    required super.name,
    required super.code,
    super.departmentId,
    super.departmentName,
  });

  factory RoleSearchResultModel.fromJson(Map<String, dynamic> json) {
    final department = json['department'] is Map
        ? Map<String, dynamic>.from(json['department'] as Map)
        : const <String, dynamic>{};
    final departmentId = _asInt(
      department['id'] ?? json['department_id'],
    );
    final departmentName = _asText(
      department['name'] ?? json['department_name'],
    );
    return RoleSearchResultModel(
      id: _asInt(json['id']),
      name: _asText(json['name']),
      code: _asText(json['code']),
      departmentId: departmentId > 0 ? departmentId : null,
      departmentName: departmentName.isEmpty ? null : departmentName,
    );
  }
}

class EmployeeSearchResultModel extends OrganizationSearchEmployeeEntity {
  const EmployeeSearchResultModel({
    required super.id,
    required super.userName,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.fatherName,
    required super.motherName,
    required super.nationalId,
    required super.isActive,
    required super.assignments,
  });

  factory EmployeeSearchResultModel.fromJson(Map<String, dynamic> json) =>
      EmployeeSearchResultModel(
        id: _asInt(json['id']),
        userName: _asText(json['userName']),
        email: _asText(json['email']),
        firstName: _asText(json['first_name']),
        lastName: _asText(json['last_name']),
        fatherName: _asText(json['father_name']),
        motherName: _asText(json['mother_name']),
        nationalId: _asText(json['national_id']),
        isActive: _asBool(json['is_active']),
        assignments: _maps(json['assignments'])
            .map(AssignmentSearchModel.fromJson)
            .where((item) =>
                item.assignmentId > 0 &&
                item.departmentId > 0 &&
                item.roleId > 0)
            .toList(growable: false),
      );
}

class AssignmentSearchModel extends OrganizationSearchAssignmentEntity {
  const AssignmentSearchModel({
    required super.assignmentId,
    required super.odrId,
    required super.roleId,
    required super.roleName,
    required super.roleCode,
    required super.departmentId,
    required super.departmentName,
  });

  factory AssignmentSearchModel.fromJson(Map<String, dynamic> json) {
    final role = json['role'] is Map
        ? Map<String, dynamic>.from(json['role'] as Map)
        : const <String, dynamic>{};
    final department = json['department'] is Map
        ? Map<String, dynamic>.from(json['department'] as Map)
        : const <String, dynamic>{};
    return AssignmentSearchModel(
      assignmentId: _asInt(json['assignment_id']),
      odrId: _asInt(json['odr_id']),
      roleId: _asInt(role['id']),
      roleName: _asText(role['name']),
      roleCode: _asText(role['code']),
      departmentId: _asInt(department['id']),
      departmentName: _asText(department['name']),
    );
  }
}

class OrganizationSearchPaginationModel
    extends OrganizationSearchPaginationEntity {
  const OrganizationSearchPaginationModel({
    required super.limit,
    required super.departmentsHasNext,
    required super.rolesHasNext,
    required super.employeesHasNext,
  });

  factory OrganizationSearchPaginationModel.fromJson(
    Map<String, dynamic> json,
  ) =>
      OrganizationSearchPaginationModel(
        limit: _asInt(json['limit']),
        departmentsHasNext: _asBool(json['departments_has_next']),
        rolesHasNext: _asBool(json['roles_has_next']),
        employeesHasNext: _asBool(json['employees_has_next']),
      );
}

List<Map<String, dynamic>> _maps(dynamic value) => value is List
    ? value.whereType<Map>().map(Map<String, dynamic>.from).toList()
    : const [];

int _asInt(dynamic value) =>
    value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;

String _asText(dynamic value) => value?.toString().trim() ?? '';

bool _asBool(dynamic value) =>
    value == true || value == 1 || value?.toString().toLowerCase() == 'true';
