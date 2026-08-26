import '../../domain/entities/employee_search_result_entity.dart';
import 'statistics_employee_details_model.dart';

class EmployeeSearchResultModel extends EmployeeSearchResultEntity {
  const EmployeeSearchResultModel({
    required super.items,
    required super.pagination,
  });

  factory EmployeeSearchResultModel.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']);
    final itemsList = data['items'] as List? ?? [];
    final paginationMap = _asMap(data['pagination']);

    return EmployeeSearchResultModel(
      items: itemsList
          .whereType<Map>()
          .map(
            (item) => EmployeeSearchItemModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      pagination: EmployeeSearchPaginationModel.fromJson(paginationMap),
    );
  }
}

class EmployeeSearchItemModel extends EmployeeSearchItemEntity {
  const EmployeeSearchItemModel({
    required super.id,
    required super.userName,
    required super.email,
    required super.phoneNumber,
    required super.firstName,
    required super.lastName,
    required super.fatherName,
    required super.motherName,
    required super.nationalId,
    required super.isActive,
    required super.organization,
    required super.department,
    required super.role,
    required super.organizationDepartmentRolesId,
    super.createdAt,
    super.updatedAt,
  });

  factory EmployeeSearchItemModel.fromJson(Map<String, dynamic> json) {
    return EmployeeSearchItemModel(
      id: _asInt(json['id']),
      userName: _asString(json['userName']),
      email: _asString(json['email']),
      phoneNumber: _asString(json['phone_number']),
      firstName: _asString(json['first_name']),
      lastName: _asString(json['last_name']),
      fatherName: _asString(json['father_name']),
      motherName: _asString(json['mother_name']),
      nationalId: _asString(json['national_id']),
      isActive: _asBool(json['is_active']),
      organization: EmployeeOrganizationModel.fromJson(
        _asMap(json['organization']),
      ),
      department: EmployeeDepartmentModel.fromJson(
        _asMap(json['department']),
      ),
      role: EmployeeRoleModel.fromJson(_asMap(json['role'])),
      organizationDepartmentRolesId:
          _asInt(json['organization_department_roles_id']),
      createdAt: _asDateTime(json['created_at']),
      updatedAt: _asDateTime(json['updated_at']),
    );
  }
}

class EmployeeSearchPaginationModel extends EmployeeSearchPaginationEntity {
  const EmployeeSearchPaginationModel({
    required super.limit,
    super.cursor,
    super.nextCursor,
    required super.hasNext,
    required super.hasPrev,
  });

  factory EmployeeSearchPaginationModel.fromJson(Map<String, dynamic> json) {
    return EmployeeSearchPaginationModel(
      limit: _asInt(json['limit']) == 0 ? 6 : _asInt(json['limit']),
      cursor: json['cursor']?.toString(),
      nextCursor: json['next_cursor']?.toString(),
      hasNext: _asBool(json['has_next']),
      hasPrev: _asBool(json['has_prev']),
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

int _asInt(dynamic value) =>
    value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;

String _asString(dynamic value) => value?.toString().trim() ?? '';

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return value?.toString().toLowerCase() == 'true';
}

DateTime? _asDateTime(dynamic value) =>
    DateTime.tryParse(value?.toString() ?? '');
