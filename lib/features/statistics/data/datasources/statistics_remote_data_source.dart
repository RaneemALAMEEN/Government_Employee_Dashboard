import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../../core/enums/api_method.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/api_const.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/statistics_employee_model.dart';
import '../models/statistics_employee_details_model.dart';
import '../models/statistics_process_model.dart';
import '../models/statistics_pagination_model.dart';
import '../../domain/entities/statistics_paginated_result.dart';

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
      (failure) => throw StatisticsDataSourceException(failure),
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

  Future<StatisticsPaginatedResult<StatisticsEmployeeModel>>
      getEmployeesByDepartments({
    required List<int> departmentIds,
    required int limit,
    String? cursor,
  }) async {
    final departmentIdsQuery = await _resolveDepartmentIdsQuery(departmentIds);
    final result = await apiService.makeRequest(
      method: ApiMethod.get,
      endPoint: _endPoints.employeesByDepartments,
      queryParameters: {
        if (departmentIdsQuery != null) 'department_ids': departmentIdsQuery,
        'limit': limit,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      },
    );

    return result.fold(
      (failure) => throw StatisticsDataSourceException(failure),
      (response) {
        final data = response['data'] as Map<String, dynamic>? ?? {};
        final items = data['items'] as List? ?? [];

        final employees = items
            .whereType<Map>()
            .map(
              (item) => StatisticsEmployeeModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
        return StatisticsPaginatedResult(
          items: employees,
          pagination: StatisticsPaginationModel.fromJson(
            _asMap(data['pagination']),
            requestedLimit: limit,
          ),
        );
      },
    );
  }

  Future<StatisticsPaginatedResult<StatisticsProcessModel>>
      getProcessDefinitionStats({
    required List<int> departmentIds,
    required int limit,
    String? cursor,
    String? fromDate,
    String? toDate,
  }) async {
    final departmentIdsQuery = await _resolveDepartmentIdsQuery(departmentIds);
    final result = await apiService.makeRequest(
      method: ApiMethod.get,
      endPoint: _endPoints.processDefinitionStats,
      queryParameters: {
        if (departmentIdsQuery != null) 'department_ids': departmentIdsQuery,
        'limit': limit,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        if (fromDate != null && fromDate.isNotEmpty) 'from_date': fromDate,
        if (toDate != null && toDate.isNotEmpty) 'to_date': toDate,
      },
    );

    return result.fold(
      (failure) => throw StatisticsDataSourceException(failure),
      (response) {
        final data = response['data'] as Map<String, dynamic>? ?? {};
        final items = data['items'] as List? ?? [];

        final processes = items
            .whereType<Map>()
            .map(
              (item) => StatisticsProcessModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
        return StatisticsPaginatedResult(
          items: processes,
          pagination: StatisticsPaginationModel.fromJson(
            _asMap(data['pagination']),
            requestedLimit: limit,
          ),
        );
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

Map<String, dynamic> _asMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

class StatisticsDataSourceException implements Exception {
  final Failure failure;

  const StatisticsDataSourceException(this.failure);
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
