import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../../core/enums/api_method.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/api_const.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/statistics_paginated_result.dart';
import '../models/employee_search_result_model.dart';
import '../models/process_search_result_model.dart';
import '../models/statistics_employee_details_model.dart';
import '../models/statistics_employee_model.dart';
import '../models/statistics_pagination_model.dart';
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

  Future<EmployeeSearchResultModel> searchEmployees({
    String? query,
    String? cursor,
    int limit = 6,
  }) async {
    final cleanQuery = query?.trim();
    final queryParameters = <String, dynamic>{
      'limit': limit,
      if (cleanQuery != null && cleanQuery.isNotEmpty) ...{
        'q': cleanQuery,
        'search': cleanQuery,
      },
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
    };

    final result = await apiService.makeRequest(
      method: ApiMethod.get,
      endPoint: _endPoints.searchEmployees,
      queryParameters: queryParameters,
    );

    return result.fold(
      (failure) => throw StatisticsDataSourceException(failure),
      (response) {
        if (response is! Map) {
          throw const ServerException('استجابة بحث الموظفين غير صالحة');
        }
        return EmployeeSearchResultModel.fromJson(
          Map<String, dynamic>.from(response),
        );
      },
    );
  }

  Future<ProcessSearchResultModel> searchProcessDefinitions({
    required int organizationId,
    String? query,
    String? cursor,
    int limit = 6,
    int? typeTransId,
    bool? isComplaint,
  }) async {
    final cleanQuery = query?.trim();
    final queryParameters = <String, dynamic>{
      'organization_id': organizationId,
      'limit': limit,
      if (cleanQuery != null && cleanQuery.isNotEmpty) ...{
        'q': cleanQuery,
      },
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      if (typeTransId != null) 'type_trans_id': typeTransId,
      if (isComplaint != null) 'is_complaint': isComplaint,
    };

    final result = await apiService.makeRequest(
      method: ApiMethod.get,
      endPoint: _endPoints.organizationProcessDefinitionsSearch,
      queryParameters: queryParameters,
    );

    return result.fold(
      (failure) => throw StatisticsDataSourceException(failure),
      (response) {
        if (response is! Map) {
          throw const ServerException('استجابة بحث المعاملات غير صالحة');
        }
        return ProcessSearchResultModel.fromJson(
          Map<String, dynamic>.from(response),
        );
      },
    );
  }

  Future<StatisticsPaginatedResult<StatisticsEmployeeModel>>
      getEmployeesByDepartments({
    required List<int> departmentIds,
    int limit = 6,
    String? cursor,
  }) async {
    final departmentIdsQuery = await _resolveDepartmentIdsQuery(departmentIds);
    final result = await apiService.makeRequest(
      method: ApiMethod.get,
      endPoint: _endPoints.employeesByDepartments,
      queryParameters: {
        'limit': limit,
        if (departmentIdsQuery != null) 'department_ids': departmentIdsQuery,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      },
    );

    return result.fold(
      (failure) => throw StatisticsDataSourceException(failure),
      (response) {
        if (response is! Map) {
          throw const ServerException('استجابة إحصائيات الموظفين غير صالحة');
        }
        final data = response['data'] as Map<String, dynamic>? ?? {};
        final items = data['items'] as List? ?? [];
        final paginationMap = data['pagination'] as Map<String, dynamic>?;

        final employees = items
            .whereType<Map>()
            .map(
              (item) => StatisticsEmployeeModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();

        final pagination = paginationMap != null
            ? StatisticsPaginationModel.fromJson(
                paginationMap,
                requestedLimit: limit,
              )
            : StatisticsPaginationModel(
                limit: limit,
                cursor: cursor,
                nextCursor: null,
                hasNext: false,
                hasPrev: false,
              );

        return StatisticsPaginatedResult<StatisticsEmployeeModel>(
          items: employees,
          pagination: pagination,
        );
      },
    );
  }

  Future<StatisticsPaginatedResult<StatisticsProcessModel>>
      getProcessDefinitionStats({
    required List<int> departmentIds,
    int limit = 6,
    String? cursor,
    String? fromDate,
    String? toDate,
  }) async {
    final departmentIdsQuery = await _resolveDepartmentIdsQuery(departmentIds);
    final result = await apiService.makeRequest(
      method: ApiMethod.get,
      endPoint: _endPoints.processDefinitionStats,
      queryParameters: {
        'limit': limit,
        if (departmentIdsQuery != null) 'department_ids': departmentIdsQuery,
        if (fromDate != null && fromDate.isNotEmpty) 'from_date': fromDate,
        if (toDate != null && toDate.isNotEmpty) 'to_date': toDate,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      },
    );

    return result.fold(
      (failure) => throw StatisticsDataSourceException(failure),
      (response) {
        if (response is! Map) {
          throw const ServerException('استجابة إحصائيات المعاملات غير صالحة');
        }
        final data = response['data'] as Map<String, dynamic>? ?? {};
        final items = data['items'] as List? ?? [];
        final paginationMap = data['pagination'] as Map<String, dynamic>?;

        final processes = items
            .whereType<Map>()
            .map(
              (item) => StatisticsProcessModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();

        final pagination = paginationMap != null
            ? StatisticsPaginationModel.fromJson(
                paginationMap,
                requestedLimit: limit,
              )
            : StatisticsPaginationModel(
                limit: limit,
                cursor: cursor,
                nextCursor: null,
                hasNext: false,
                hasPrev: false,
              );

        return StatisticsPaginatedResult<StatisticsProcessModel>(
          items: processes,
          pagination: pagination,
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
