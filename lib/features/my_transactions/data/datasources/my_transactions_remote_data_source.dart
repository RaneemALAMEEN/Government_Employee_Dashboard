import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart' as dio;

import '../../../../core/enums/api_method.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/api_service.dart';

class MyTransactionsRemoteDataSource {
  final ApiService api;

  MyTransactionsRemoteDataSource(this.api);

  Future<Either<Failure, dynamic>> getTasks({
    required String status,
    String? cursor,
    int limit = 6,
  }) {
    final queryParameters = <String, dynamic>{
      'status': status,
      'limit': limit,
    };
    if (cursor != null && cursor.isNotEmpty) {
      queryParameters['cursor'] = cursor;
    }
    return api.makeRequest(
      method: ApiMethod.get,
      endPoint: 'api/workflow/tasks',
      queryParameters: queryParameters,
    );
  }

  Future<Either<Failure, dynamic>> searchTasks({
    required String status,
    String? query,
    String? fromDate,
    String? toDate,
    String? cursor,
    int limit = 6,
  }) {
    final queryParameters = <String, dynamic>{
      'limit': limit,
    };
    if (status.isNotEmpty) {
      queryParameters['status'] = status;
    }
    if (query != null && query.isNotEmpty) {
      queryParameters['q'] = query;
    }
    if (cursor != null && cursor.isNotEmpty) {
      queryParameters['cursor'] = cursor;
    }
    if (fromDate != null && fromDate.isNotEmpty) {
      queryParameters['from_date'] = fromDate;
    }
    if (toDate != null && toDate.isNotEmpty) {
      queryParameters['to_date'] = toDate;
    }

    return api.makeRequest(
      method: ApiMethod.get,
      endPoint: 'api/workflow/tasks/search',
      queryParameters: queryParameters,
    );
  }

  Future<Either<Failure, dynamic>> getTaskDetails({
    required String taskId,
  }) {
    return api.makeRequest(
      method: ApiMethod.get,
      endPoint: 'api/workflow/tasks/$taskId',
    );
  }

  Future<Either<Failure, dynamic>> getTransactionCertificate({
    required String taskId,
  }) async {
    final result = await api.makeRequest(
      method: ApiMethod.get,
      endPoint: 'api/workflow/transactions/$taskId/certificate',
    );
    if (result.isRight()) {
      return result;
    }
    return api.makeRequest(
      method: ApiMethod.get,
      endPoint: 'api/transaction/$taskId/certificate',
    );
  }

  Future<Either<Failure, dynamic>> pickupTask({
    required String taskId,
  }) {
    return api.makeRequest(
      method: ApiMethod.post,
      endPoint: 'api/workflow/tasks/$taskId/pickup',
    );
  }

  Future<Either<Failure, dynamic>> releaseTask({
    required String taskId,
  }) {
    return api.makeRequest(
      method: ApiMethod.post,
      endPoint: 'api/workflow/tasks/$taskId/release',
    );
  }

  Future<Either<Failure, dynamic>> createSigningChallenge({
    required String taskId,
    required Map<String, dynamic> payload,
    bool isSubmitDocuments = false,
  }) async {
    final endPoint = isSubmitDocuments
        ? 'api/workflow/tasks/$taskId/submit-documents/signing-challenge'
        : 'api/workflow/tasks/$taskId/signing-challenge';

    print('======================================================================');
    print('🚀 [API REQUEST] POST $endPoint');
    print('Task ID: $taskId');
    print('--- Request Body (JSON) ---');
    try {
      const encoder = JsonEncoder.withIndent('  ');
      print(encoder.convert(payload));
    } catch (_) {
      print(payload.toString());
    }
    print('----------------------------------------------------------------------');

    final result = await api.makeRequest(
      method: ApiMethod.post,
      endPoint: endPoint,
      body: payload,
    );

    print('📥 [API RESPONSE] POST $endPoint');
    result.fold(
      (failure) => print('❌ Failure: ${failure.message}'),
      (response) {
        print('✅ Success Response (JSON):');
        try {
          const encoder = JsonEncoder.withIndent('  ');
          print(encoder.convert(response));
        } catch (_) {
          print(response.toString());
        }
      },
    );
    print('======================================================================');

    return result;
  }

  Future<Either<Failure, dynamic>> completeTask({
    required String taskId,
    required Map<String, dynamic> payload,
    bool isSubmitDocuments = false,
  }) async {
    final endPoint = isSubmitDocuments
        ? 'api/workflow/tasks/$taskId/submit-documents/complete'
        : 'api/workflow/tasks/$taskId/complete';

    print('======================================================================');
    print('🚀 [API REQUEST] POST $endPoint');
    print('Task ID: $taskId');
    print('--- Request Body (JSON) ---');
    try {
      const encoder = JsonEncoder.withIndent('  ');
      print(encoder.convert(payload));
    } catch (_) {
      print(payload.toString());
    }
    print('----------------------------------------------------------------------');

    final result = await api.makeRequest(
      method: ApiMethod.post,
      endPoint: endPoint,
      body: payload,
    );

    print('📥 [API RESPONSE] POST $endPoint');
    result.fold(
      (failure) => print('❌ Failure: ${failure.message}'),
      (response) {
        print('✅ Success Response (JSON):');
        try {
          const encoder = JsonEncoder.withIndent('  ');
          print(encoder.convert(response));
        } catch (_) {
          print(response.toString());
        }
      },
    );
    print('======================================================================');

    return result;
  }

  Future<Either<Failure, dynamic>> uploadTransactionFile({
    required String filePath,
    required int typeDocId,
    required String key,
    dio.ProgressCallback? onSendProgress,
  }) async {
    final formData = dio.FormData.fromMap({
      'file': await dio.MultipartFile.fromFile(filePath),
      'type_doc_id': typeDocId,
      'key': key,
    });

    return api.makeRequest(
      method: ApiMethod.post,
      endPoint: '/api/transaction/files/upload',
      formData: formData,
      onSendProgress: onSendProgress,
    );
  }

  Future<Either<Failure, dynamic>> getDocumentTemplate({
    required int templateId,
  }) {
    return api.makeRequest(
      method: ApiMethod.get,
      endPoint: 'api/document-templates/$templateId',
    );
  }
}
