import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';

import '../../../../core/enums/api_method.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/api_const.dart';
import '../../../../core/services/api_service.dart';

class InternalTransactionsRemoteDataSource {
  final ApiService apiService;

  InternalTransactionsRemoteDataSource(this.apiService);

  static const _endPoints = EndPoints();

  Future<Map<String, dynamic>> getCategories() async {
    final result = await apiService.makeRequest(
      method: ApiMethod.get,
      endPoint: _endPoints.typeProcess,
    );

    return result.fold(
      (failure) => throw ServerException(failure.message),
      (response) {
        if (response is Map<String, dynamic>) {
          return response;
        }
        return {'data': response};
      },
    );
  }

  Future<Map<String, dynamic>> getStageConfig({
    required int processId,
  }) async {
    final result = await apiService.makeRequest(
      method: ApiMethod.get,
      endPoint: _endPoints.stageConfig(processId),
    );

    return result.fold(
      (failure) => throw ServerException(failure.message),
      (response) {
        if (response is Map<String, dynamic>) {
          return response;
        }
        return <String, dynamic>{};
      },
    );
  }

  Future<Map<String, dynamic>> uploadTransactionFile({
    required String filePath,
    required int typeDocId,
    required String key,
  }) async {
    debugPrint(
      '[TransactionAttachment] بدء الرفع إلى '
      '${_endPoints.uploadTransactionFile} | '
      'key=$key | type_doc_id=$typeDocId | file=$filePath',
    );

    final formData = dio.FormData.fromMap({
      'file': await dio.MultipartFile.fromFile(filePath),
      'type_doc_id': typeDocId,
      'key': key,
    });

    final result = await apiService.makeRequest(
      method: ApiMethod.post,
      endPoint: _endPoints.uploadTransactionFile,
      formData: formData,
    );

    return result.fold(
      (failure) => throw ServerException(failure.message),
      (response) {
        if (response is! Map) {
          throw const ServerException('استجابة رفع الملف غير صالحة');
        }

        final responseMap = Map<String, dynamic>.from(response);
        final nestedData = responseMap['data'];
        final uploadedFile = nestedData is Map
            ? Map<String, dynamic>.from(nestedData)
            : responseMap;
        final uploadedPath = uploadedFile['path']?.toString();

        if (uploadedPath == null || uploadedPath.isEmpty) {
          throw const ServerException('لم يُرجع الخادم مسار الملف المرفوع');
        }

        debugPrint(
          '[TransactionAttachment] تم الرفع إلى السيرفر بنجاح | '
          'key=$key | type_doc_id=$typeDocId | path=$uploadedPath',
        );

        return {
          'key': uploadedFile['key']?.toString() ?? key,
          'path': uploadedPath,
          'type_doc_id': uploadedFile['type_doc_id'] ?? typeDocId,
        };
      },
    );
  }

  Future<Map<String, dynamic>> getProcessesByCategory({
    required int categoryId,
    required int page,
    required int limit,
  }) async {
    final result = await apiService.makeRequest(
      method: ApiMethod.get,
      endPoint: _endPoints.processDefinitionsAuth(categoryId),
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    return result.fold(
      (failure) => throw ServerException(failure.message),
      (response) {
        if (response is Map<String, dynamic>) {
          final data = response['data'];
          if (data is Map<String, dynamic>) return data;
          return response;
        }
        return <String, dynamic>{};
      },
    );
  }

  Future<Map<String, dynamic>> getMyTransactionCounts() async {
    final result = await apiService.makeRequest(
      method: ApiMethod.get,
      endPoint: _endPoints.myTransactionCounts,
    );

    return result.fold(
      (failure) => throw ServerException(failure.message),
      (response) {
        if (response is Map<String, dynamic>) {
          final data = response['data'];
          if (data is Map<String, dynamic>) return data;
          return response;
        }
        return <String, dynamic>{};
      },
    );
  }

  Future<Map<String, dynamic>> getMyTransactions({
    required int page,
    required int limit,
    String? status,
  }) async {
    final result = await apiService.makeRequest(
      method: ApiMethod.get,
      endPoint: _endPoints.myTransactions,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );

    return result.fold(
      (failure) => throw ServerException(failure.message),
      (response) {
        if (response is Map<String, dynamic>) {
          final data = response['data'];
          if (data is Map<String, dynamic>) return data;
          return response;
        }
        return <String, dynamic>{};
      },
    );
  }

  Future<Map<String, dynamic>> getFirstStageTransaction({
    required int transactionId,
  }) async {
    final result = await apiService.makeRequest(
      method: ApiMethod.get,
      endPoint: _endPoints.firstStageTransaction(transactionId),
    );

    return result.fold(
      (failure) => throw ServerException(failure.message),
      (response) {
        if (response is Map<String, dynamic>) return response;
        return <String, dynamic>{};
      },
    );
  }

  Future<Map<String, dynamic>> createSigningChallenge({
    required int processId,
    required String pin,
  }) async {
    final result = await apiService.makeRequest(
      method: ApiMethod.post,
      endPoint: _endPoints.signingChallenge(processId),
      body: {
        'pin': pin,
      },
    );

    return result.fold(
      (failure) => throw ServerException(failure.message),
      (response) {
        final data = response['data'] as Map<String, dynamic>? ?? {};
        return data;
      },
    );
  }

  Future<Map<String, dynamic>> completeSignedTransaction({
    required int transactionId,
    required Map<String, dynamic> payload,
  }) async {
    final endpoint = _endPoints.completeSignedTransaction(transactionId);
    debugPrint('[SigningFlow] complete endpoint request = POST $endpoint');
    final result = await apiService.makeRequest(
      method: ApiMethod.post,
      endPoint: endpoint,
      body: payload,
    );

    return result.fold(
      (failure) {
        debugPrint('[SigningFlow] complete endpoint succeeded = false');
        throw ServerException(failure.message);
      },
      (response) {
        debugPrint('[SigningFlow] complete endpoint succeeded = true');
        return response as Map<String, dynamic>;
      },
    );
  }

  Future<Map<String, dynamic>> getDocumentTemplate({
    required int templateId,
  }) async {
    final result = await apiService.makeRequest(
      method: ApiMethod.get,
      endPoint: _endPoints.documentTemplate(templateId),
    );

    return result.fold(
      (failure) => throw ServerException(failure.message),
      (response) {
        if (response is Map<String, dynamic>) return response;
        return <String, dynamic>{};
      },
    );
  }
}
