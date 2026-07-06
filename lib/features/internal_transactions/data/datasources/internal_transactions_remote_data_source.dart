import 'package:dio/dio.dart' as dio;
import 'package:government_employee_dashboard/features/internal_transactions/domain/entities/document_template_entity.dart';

import '../../../../core/enums/api_method.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/api_const.dart';
import '../../../../core/services/api_service.dart';
import '../../domain/entities/dynamic_form_entity.dart';
import '../../domain/entities/internal_category_entity.dart';
import '../../domain/entities/internal_processes_page_entity.dart';
import '../../domain/entities/internal_transaction_counts_entity.dart';
import '../../domain/entities/internal_transactions_page_entity.dart';
import '../models/document_template_model.dart';
import '../models/dynamic_form_model.dart';
import '../models/internal_category_model.dart';
import '../models/internal_processes_page_model.dart';
import '../models/internal_transaction_first_stage_model.dart';
import '../models/internal_transaction_counts_model.dart';
import '../models/internal_transactions_page_model.dart';

class InternalTransactionsRemoteDataSource {
  final ApiService apiService;

  InternalTransactionsRemoteDataSource(this.apiService);

  static const _endPoints = EndPoints();

  Future<List<InternalCategoryEntity>> getCategories() async {
    final result = await apiService.makeRequest(
      method: ApiMethod.get,
      endPoint: _endPoints.typeProcess,
    );

    return result.fold(
      (failure) => throw ServerException(failure.message),
      (response) {
        final data = response['data'] as List? ?? [];

        return data
            .map((item) => InternalCategoryModel.fromJson(item))
            .toList();
      },
    );
  }

  Future<DynamicFormEntity> getStageConfig({
    required int processId,
  }) async {
    final result = await apiService.makeRequest(
      method: ApiMethod.get,
      endPoint: _endPoints.stageConfig(processId),
    );

    return result.fold(
      (failure) => throw ServerException(failure.message),
      (response) {
        final data = response['data'] as Map<String, dynamic>? ?? response;
        return DynamicFormModel.fromJson(data);
      },
    );
  }

  Future<Map<String, dynamic>> uploadTransactionFile({
    required String filePath,
    required int typeDocId,
    required String key,
  }) async {
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
        final data = response['data'] as Map<String, dynamic>? ?? {};
        return data;
      },
    );
  }

  Future<InternalProcessesPageEntity> getProcessesByCategory({
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
        final data = response['data'] as Map<String, dynamic>? ?? {};
        return InternalProcessesPageModel.fromJson(data);
      },
    );
  }

  Future<InternalTransactionCountsEntity> getMyTransactionCounts() async {
    final result = await apiService.makeRequest(
      method: ApiMethod.get,
      endPoint: _endPoints.myTransactionCounts,
    );

    return result.fold(
      (failure) => throw ServerException(failure.message),
      (response) {
        final data = response['data'] as Map<String, dynamic>? ?? {};
        return InternalTransactionCountsModel.fromJson(data);
      },
    );
  }

  Future<InternalTransactionsPageEntity> getMyTransactions({
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
        final data = response['data'] as Map<String, dynamic>? ?? {};
        return InternalTransactionsPageModel.fromJson(data);
      },
    );
  }

  Future<InternalTransactionFirstStageModel> getFirstStageTransaction({
    required int transactionId,
  }) async {
    final result = await apiService.makeRequest(
      method: ApiMethod.get,
      endPoint: _endPoints.firstStageTransaction(transactionId),
    );

    return result.fold(
      (failure) => throw ServerException(failure.message),
      (response) => InternalTransactionFirstStageModel.fromJson(
        response as Map<String, dynamic>,
      ),
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
    final result = await apiService.makeRequest(
      method: ApiMethod.post,
      endPoint: _endPoints.completeSignedTransaction(transactionId),
      body: payload,
    );

    return result.fold(
      (failure) => throw ServerException(failure.message),
      (response) => response as Map<String, dynamic>,
    );
  }

  Future<DocumentTemplateEntity> getDocumentTemplate({
    required int templateId,
  }) async {
    final result = await apiService.makeRequest(
      method: ApiMethod.get,
      endPoint: _endPoints.documentTemplate(templateId),
    );

    return result.fold(
      (failure) => throw ServerException(failure.message),
      (response) {
        return DocumentTemplateModel.fromJson(
          response as Map<String, dynamic>,
        );
      },
    );
  }
}
