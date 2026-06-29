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
    int page = 1,
    int limit = 50,
  }) {
    return api.makeRequest(
      method: ApiMethod.get,
      endPoint: 'api/workflow/tasks',
      queryParameters: {
        'status': status,
        'page': page,
        'limit': limit,
      },
    );
  }

  Future<Either<Failure, dynamic>> getInProgressTasks({
    int page = 1,
    int limit = 50,
  }) {
    return api.makeRequest(
      method: ApiMethod.get,
      endPoint: 'api/workflow/tasks/in-progress',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );
  }

  Future<Either<Failure, dynamic>> getPendingPickupTasks({
    int page = 1,
    int limit = 50,
  }) {
    return api.makeRequest(
      method: ApiMethod.get,
      endPoint: 'api/workflow/tasks/pending-pickup',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
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
    required String pin,
    required String decision,
    bool isSubmitDocuments = false,
  }) {
    final endPoint = isSubmitDocuments
        ? 'api/workflow/tasks/$taskId/submit-documents/signing-challenge'
        : 'api/workflow/tasks/$taskId/signing-challenge';
    return api.makeRequest(
      method: ApiMethod.post,
      endPoint: endPoint,
      body: isSubmitDocuments
          ? {
              'pin': pin,
            }
          : {
              'pin': pin,
              'decision': decision,
            },
    );
  }

  Future<Either<Failure, dynamic>> completeTask({
    required String taskId,
    required Map<String, dynamic> payload,
    bool isSubmitDocuments = false,
  }) {
    final endPoint = isSubmitDocuments
        ? 'api/workflow/tasks/$taskId/submit-documents/complete'
        : 'api/workflow/tasks/$taskId/complete';
    return api.makeRequest(
      method: ApiMethod.post,
      endPoint: endPoint,
      body: payload,
    );
  }

  Future<Either<Failure, dynamic>> uploadTransactionFile({
    required String filePath,
    required int typeDocId,
    required String key,
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
    );
  }
}
