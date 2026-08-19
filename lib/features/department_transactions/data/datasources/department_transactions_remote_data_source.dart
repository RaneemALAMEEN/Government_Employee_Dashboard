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
    String? cursor,
    int limit = 6,
  }) {
    final queryParams = <String, dynamic>{
      'limit': limit,
    };
    if (cursor != null && cursor.isNotEmpty) {
      queryParams['cursor'] = cursor;
    }
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
    String? cursor,
    int limit = 6,
  }) {
    final queryParams = <String, dynamic>{
      'limit': limit,
    };
    if (cursor != null && cursor.isNotEmpty) {
      queryParams['cursor'] = cursor;
    }
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

  Future<Either<Failure, dynamic>> getTransactionCertificate(String transactionId) async {
    final parsedId = int.tryParse(transactionId) ?? transactionId;
    return api.makeRequest(
      method: ApiMethod.get,
      endPoint: 'api/verify/document/details/by-transaction',
      queryParameters: {'transaction_id': parsedId},
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

  Future<Either<Failure, dynamic>> getAccessibleScope() {
    return api.makeRequest(
      method: ApiMethod.get,
      endPoint: 'api/department/accessible-scope',
    );
  }

  Future<Either<Failure, dynamic>> searchCompletedTransactions({
    required String departmentIds,
    String? query,
    String? fromDate,
    String? toDate,
    String? cursor,
    int limit = 6,
  }) {
    final queryParams = <String, dynamic>{
      'department_ids': departmentIds,
      'limit': limit,
    };
    if (query != null && query.isNotEmpty) {
      queryParams['q'] = query;
    }
    if (cursor != null && cursor.isNotEmpty) {
      queryParams['cursor'] = cursor;
    }
    if (fromDate != null && fromDate.isNotEmpty) {
      queryParams['from_date'] = fromDate;
    }
    if (toDate != null && toDate.isNotEmpty) {
      queryParams['to_date'] = toDate;
    }

    return api.makeRequest(
      method: ApiMethod.get,
      endPoint: 'api/transaction/search',
      queryParameters: queryParams,
    );
  }

  Future<Either<Failure, dynamic>> searchRejectedTransactions({
    required String departmentIds,
    String? query,
    String? fromDate,
    String? toDate,
    String? cursor,
    int limit = 6,
  }) {
    final queryParams = <String, dynamic>{
      'department_ids': departmentIds,
      'limit': limit,
    };
    if (query != null && query.isNotEmpty) {
      queryParams['q'] = query;
    }
    if (cursor != null && cursor.isNotEmpty) {
      queryParams['cursor'] = cursor;
    }
    if (fromDate != null && fromDate.isNotEmpty) {
      queryParams['from_date'] = fromDate;
    }
    if (toDate != null && toDate.isNotEmpty) {
      queryParams['to_date'] = toDate;
    }

    return api.makeRequest(
      method: ApiMethod.get,
      endPoint: 'api/transaction/search/rejected',
      queryParameters: queryParams,
    );
  }

  Future<Either<Failure, dynamic>> getSourceDocuments(int transactionId) {
    return api.makeRequest(
      method: ApiMethod.get,
      endPoint: 'api/transaction/$transactionId/source-documents',
    );
  }

  Future<Either<Failure, dynamic>> getOrGenerateFinalDocument(
    int transactionId, {
    String? fileOrder,
    String? documentSignatureIds,
    String? documentInstanceIds,
  }) {
    final queryParams = <String, dynamic>{};
    if (fileOrder != null) {
      queryParams['file_order'] = fileOrder;
    }
    if (documentSignatureIds != null && documentSignatureIds.isNotEmpty) {
      queryParams['document_signature_ids'] = documentSignatureIds;
    }
    if (documentInstanceIds != null && documentInstanceIds.isNotEmpty) {
      queryParams['document_instance_ids'] = documentInstanceIds;
    }

    return api.makeRequest(
      method: ApiMethod.get,
      endPoint: 'api/transaction/$transactionId/final-document',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
  }

  Future<Either<Failure, dynamic>> deleteFinalDocument(int transactionId) {
    return api.makeRequest(
      method: ApiMethod.delete,
      endPoint: 'api/transaction/$transactionId/final-document',
    );
  }
}


