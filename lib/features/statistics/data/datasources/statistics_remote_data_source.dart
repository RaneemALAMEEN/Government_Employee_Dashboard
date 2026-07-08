import '../../../../core/enums/api_method.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/api_const.dart';
import '../../../../core/services/api_service.dart';
import '../models/statistics_employee_model.dart';
import '../models/statistics_process_model.dart';

class StatisticsRemoteDataSource {
  final ApiService apiService;

  StatisticsRemoteDataSource(this.apiService);

  static const _endPoints = EndPoints();

  Future<List<StatisticsEmployeeModel>> getEmployeesByDepartments(
      {required List<int> departmentIds}) async {
    final result = await apiService.makeRequest(
      method: ApiMethod.get,
      endPoint: _endPoints.employeesByDepartments,
      queryParameters: {'department_ids': departmentIds.join(',')},
    );

    return result.fold(
      (failure) => throw ServerException(failure.message),
      (response) {
        final data = response['data'] as Map<String, dynamic>? ?? {};
        final items = data['items'] as List? ?? [];

        return items
            .whereType<Map>()
            .map(
              (item) => StatisticsEmployeeModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      },
    );
  }

  Future<List<StatisticsProcessModel>> getProcessDefinitionStats(
      {required List<int> departmentIds}) async {
    final result = await apiService.makeRequest(
      method: ApiMethod.get,
      endPoint: _endPoints.processDefinitionStats,
      queryParameters: {'department_ids': departmentIds.join(',')},
    );

    return result.fold(
      (failure) => throw ServerException(failure.message),
      (response) {
        final data = response['data'] as Map<String, dynamic>? ?? {};
        final items = data['items'] as List? ?? [];

        return items
            .whereType<Map>()
            .map(
              (item) => StatisticsProcessModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      },
    );
  }
}
