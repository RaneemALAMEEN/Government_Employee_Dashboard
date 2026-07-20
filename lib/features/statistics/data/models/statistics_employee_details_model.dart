import '../../domain/entities/statistics_employee_details_entity.dart';

class StatisticsEmployeeDetailsModel extends StatisticsEmployeeDetailsEntity {
  const StatisticsEmployeeDetailsModel({
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
    required super.createdAt,
    required super.updatedAt,
  });

  factory StatisticsEmployeeDetailsModel.fromJson(
    Map<String, dynamic> response,
  ) {
    final data = _asMap(response['data']);
    return StatisticsEmployeeDetailsModel(
      id: _asInt(data['id']),
      userName: _asString(data['userName']),
      email: _asString(data['email']),
      phoneNumber: _asString(data['phone_number']),
      firstName: _asString(data['first_name']),
      lastName: _asString(data['last_name']),
      fatherName: _asString(data['father_name']),
      motherName: _asString(data['mother_name']),
      nationalId: _asString(data['national_id']),
      isActive: _asBool(data['is_active']),
      organization: EmployeeOrganizationModel.fromJson(
        _asMap(data['organization']),
      ),
      department: EmployeeDepartmentModel.fromJson(
        _asMap(data['department']),
      ),
      role: EmployeeRoleModel.fromJson(_asMap(data['role'])),
      organizationDepartmentRolesId:
          _asInt(data['organization_department_roles_id']),
      createdAt: _asDateTime(data['created_at']),
      updatedAt: _asDateTime(data['updated_at']),
    );
  }
}

class EmployeeOrganizationModel extends EmployeeOrganizationEntity {
  const EmployeeOrganizationModel({required super.id, required super.name});

  factory EmployeeOrganizationModel.fromJson(Map<String, dynamic> json) =>
      EmployeeOrganizationModel(
        id: _asInt(json['id']),
        name: _asString(json['name']),
      );
}

class EmployeeDepartmentModel extends EmployeeDepartmentEntity {
  const EmployeeDepartmentModel({required super.id, required super.name});

  factory EmployeeDepartmentModel.fromJson(Map<String, dynamic> json) =>
      EmployeeDepartmentModel(
        id: _asInt(json['id']),
        name: _asString(json['name']),
      );
}

class EmployeeRoleModel extends EmployeeRoleEntity {
  const EmployeeRoleModel({
    required super.id,
    required super.name,
    required super.code,
  });

  factory EmployeeRoleModel.fromJson(Map<String, dynamic> json) =>
      EmployeeRoleModel(
        id: _asInt(json['id']),
        name: _asString(json['name']),
        code: _asString(json['code']),
      );
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
