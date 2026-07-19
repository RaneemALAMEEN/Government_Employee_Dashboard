import '../../../../core/enums/api_method.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/api_const.dart';
import '../../../../core/services/api_service.dart';
import '../models/department_leaf_model.dart';
import '../models/department_role_model.dart';
import '../models/organization_employee_model.dart';

class OrganizationHierarchyRemoteDataSource {
  final ApiService apiService;
  static const _endPoints = EndPoints();

  const OrganizationHierarchyRemoteDataSource(this.apiService);

  Future<List<DepartmentLeafModel>> getDepartmentLeaves(
    int organizationId,
  ) async {
    final response = await _get(
      endPoint: _endPoints.departmentLeaves(organizationId),
    );
    final data = response['data'] as List? ?? const [];
    return data
        .whereType<Map>()
        .map((item) => DepartmentLeafModel.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .where((item) => item.id > 0 && item.fullPath.isNotEmpty)
        .toList();
  }

  Future<List<DepartmentRoleModel>> getDepartmentRoles(
    int departmentId,
  ) async {
    final response = await _get(
      endPoint: _endPoints.rolesByDepartment(departmentId),
    );
    final data = response['data'] as List? ?? const [];
    return data
        .whereType<Map>()
        .map((item) => DepartmentRoleModel.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .where((item) => item.id > 0)
        .toList();
  }

  Future<List<OrganizationEmployeeModel>> getEmployees({
    required int organizationId,
    required int departmentId,
    required int roleId,
  }) async {
    final response = await _get(
      endPoint: _endPoints.employeesByOrgDepartmentRole,
      queryParameters: {
        'organization_id': organizationId,
        'department_id': departmentId,
        'role_id': roleId,
      },
    );
    final data = response['data'] as Map<String, dynamic>? ?? const {};
    final items = data['items'] as List? ?? const [];
    return items
        .whereType<Map>()
        .map((item) => OrganizationEmployeeModel.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .where((item) => item.userId > 0 && item.isActive)
        .toList();
  }

  Future<Map<String, dynamic>> _get({
    required String endPoint,
    Map<String, dynamic>? queryParameters,
  }) async {
    final result = await apiService.makeRequest(
      method: ApiMethod.get,
      endPoint: endPoint,
      queryParameters: queryParameters,
    );

    return result.fold(
      (failure) => throw ServerException(failure.message),
      (response) {
        if (response is! Map) {
          throw const ServerException('استجابة الخادم غير صالحة.');
        }
        return Map<String, dynamic>.from(response);
      },
    );
  }
}
