import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../../core/enums/api_method.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/api_const.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/statistics_employee_model.dart';
import '../models/statistics_employee_details_model.dart';
import '../models/statistics_process_model.dart';

class StatisticsRemoteDataSource {
  final ApiService apiService;
  final SecureStorageService storage;

  StatisticsRemoteDataSource(this.apiService, this.storage);

  static const _endPoints = EndPoints();

  Future<StatisticsEmployeeDetailsModel> getEmployeeDetails({
    required int employeeId,
  }) async {
    final result = await apiService.makeRequest(
      method: ApiMethod.get,
      endPoint: _endPoints.employeeDetails(employeeId),
    );

    return result.fold(
      (failure) => throw ServerException(failure.message),
      (response) {
        if (response is! Map) {
          throw const ServerException('استجابة تفاصيل الموظف غير صالحة');
        }
        final responseMap = Map<String, dynamic>.from(response);
        if (kDebugMode) {
          const encoder = JsonEncoder.withIndent('  ');
          debugPrint(
            '[EmployeeDetails] Full response:\n'
            '${encoder.convert(_redactSensitiveData(responseMap))}',
          );
        }
        return StatisticsEmployeeDetailsModel.fromJson(responseMap);
      },
    );
  }

  Future<List<StatisticsEmployeeModel>> getEmployeesByDepartments({
    required List<int> departmentIds,
  }) async {
    final departmentIdsQuery = await _resolveDepartmentIdsQuery(departmentIds);
    final result = await apiService.makeRequest(
      method: ApiMethod.get,
      endPoint: _endPoints.employeesByDepartments,
      queryParameters: {
        if (departmentIdsQuery != null) 'department_ids': departmentIdsQuery,
      },
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

  Future<List<StatisticsProcessModel>> getProcessDefinitionStats({
    required List<int> departmentIds,
    String? fromDate,
    String? toDate,
  }) async {
    final departmentIdsQuery = await _resolveDepartmentIdsQuery(departmentIds);
    final result = await apiService.makeRequest(
      method: ApiMethod.get,
      endPoint: _endPoints.processDefinitionStats,
      queryParameters: {
        if (departmentIdsQuery != null) 'department_ids': departmentIdsQuery,
        if (fromDate != null && fromDate.isNotEmpty) 'from_date': fromDate,
        if (toDate != null && toDate.isNotEmpty) 'to_date': toDate,
      },
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

  Future<String?> _resolveDepartmentIdsQuery(List<int> departmentIds) async {
    if (departmentIds.isNotEmpty) {
      return departmentIds.join(',');
    }
    return storage.getDepartmentIds();
  }
}

dynamic _redactSensitiveData(dynamic value) {
  if (value is Map) {
    return value.map((key, nestedValue) {
      final normalizedKey =
          key.toString().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      final isSensitive = normalizedKey == 'token' ||
          normalizedKey.endsWith('token') ||
          normalizedKey.contains('authorization') ||
          normalizedKey.contains('password');
      return MapEntry(
        key.toString(),
        isSensitive ? '[REDACTED]' : _redactSensitiveData(nestedValue),
      );
    });
  }
  if (value is List) {
    return value.map(_redactSensitiveData).toList(growable: false);
  }
  return value;
}
