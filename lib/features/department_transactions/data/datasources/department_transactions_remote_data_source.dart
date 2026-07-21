import 'package:dartz/dartz.dart';

import '../../../../core/enums/api_method.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/api_service.dart';

class DepartmentTransactionsRemoteDataSource {
  final ApiService api;

  DepartmentTransactionsRemoteDataSource(this.api);

  Future<Either<Failure, dynamic>> getCompletedTransactions({
    String? departmentIds,
    String? fromDate,
    String? toDate,
    int page = 1,
    int limit = 10,
  }) {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (departmentIds != null && departmentIds.isNotEmpty) {
      queryParams['department_ids'] = departmentIds;
    }
    if (fromDate != null && fromDate.isNotEmpty) {
      queryParams['from_date'] = fromDate;
    }
    if (toDate != null && toDate.isNotEmpty) {
      queryParams['to_date'] = toDate;
    }

    return api.makeRequest(
      method: ApiMethod.get,
      endPoint: 'api/workflow/tasks/completed/by-department',
      queryParameters: queryParams,
    );
  }

  Future<Either<Failure, dynamic>> getRejectedTransactions({
    String? departmentIds,
    String? fromDate,
    String? toDate,
    int page = 1,
    int limit = 10,
  }) {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (departmentIds != null && departmentIds.isNotEmpty) {
      queryParams['department_ids'] = departmentIds;
    }
    if (fromDate != null && fromDate.isNotEmpty) {
      queryParams['from_date'] = fromDate;
    }
    if (toDate != null && toDate.isNotEmpty) {
      queryParams['to_date'] = toDate;
    }

    return api.makeRequest(
      method: ApiMethod.get,
      endPoint: 'api/workflow/tasks/rejected/by-department',
      queryParameters: queryParams,
    );
  }

  Future<Either<Failure, dynamic>> getTransactionCertificate(String transactionId) {
    return api.makeRequest(
      method: ApiMethod.get,
      endPoint: 'api/transaction/$transactionId/certificate',
    );
  }

  Future<Either<Failure, dynamic>> getCompletedStatsLastMonth({required String departmentIds}) {
    return api.makeRequest(
      method: ApiMethod.get,
      endPoint: 'api/workflow/tasks/stats/completed-last-month',
      queryParameters: {'department_ids': departmentIds},
    );
  }

  Future<Either<Failure, dynamic>> getRejectedStatsLastMonth({required String departmentIds}) {
    return api.makeRequest(
      method: ApiMethod.get,
      endPoint: 'api/workflow/tasks/stats/rejected-last-month',
      queryParameters: {'department_ids': departmentIds},
    );
  }

  Future<Either<Failure, dynamic>> getActiveStats({required String departmentIds}) {
    return api.makeRequest(
      method: ApiMethod.get,
      endPoint: 'api/workflow/tasks/stats/active',
      queryParameters: {'department_ids': departmentIds},
    );
  }
}
