import 'package:government_employee_dashboard/features/internal_transactions/data/models/internal_transaction_counts_model.dart';
import 'package:government_employee_dashboard/features/internal_transactions/domain/entities/internal_transaction_counts_entity.dart';
import '../../domain/entities/dynamic_form_entity.dart';
import 'package:dio/dio.dart' as dio;
import '../models/dynamic_form_model.dart';
import '../../../../core/enums/api_method.dart';
import '../../../../core/services/api_const.dart';
import '../../../../core/services/api_service.dart';
import '../../domain/entities/internal_category_entity.dart';
import '../../domain/entities/internal_process_entity.dart';
import '../models/internal_category_model.dart';
import '../models/internal_processes_page_model.dart';
import '../../domain/entities/internal_transaction_entity.dart';
import '../models/internal_transaction_model.dart';

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
      (failure) => throw Exception(failure.message),
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
      (failure) => throw Exception(failure.message),
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
      (failure) => throw Exception(failure.message),
      (response) {
        final data = response['data'] as Map<String, dynamic>? ?? {};
        return data;
      },
    );
  }

  Future<InternalProcessesPageData> getProcessesByCategory({
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
      (failure) => throw Exception(failure.message),
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
      (failure) => throw Exception(failure.message),
      (response) {
        final data = response['data'] as Map<String, dynamic>? ?? {};
        return InternalTransactionCountsModel.fromJson(data);
      },
    );
  }

  Future<InternalTransactionsPageData> getMyTransactions({
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
      (failure) => throw Exception(failure.message),
      (response) {
        final data = response['data'] as Map<String, dynamic>? ?? {};
        final itemsJson = data['items'] as List? ?? [];
        final pagination = data['pagination'] as Map<String, dynamic>? ?? {};

        return InternalTransactionsPageData(
          items: itemsJson
              .map(
                (item) => InternalTransactionModel.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
          page: pagination['page'] ?? 1,
          limit: pagination['limit'] ?? limit,
          total: pagination['total'] ?? 0,
          totalPages: pagination['total_pages'] ?? 1,
          hasNext: pagination['has_next'] ?? false,
          hasPrev: pagination['has_prev'] ?? false,
        );
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
      (failure) => throw Exception(failure.message),
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
    (failure) => throw Exception(failure.message),
    (response) => response as Map<String, dynamic>,
  );
}

}

class InternalProcessesPageData {
  final List<InternalProcessEntity> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  const InternalProcessesPageData({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });
}

class InternalTransactionsPageData {
  final List<InternalTransactionEntity> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  const InternalTransactionsPageData({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });
}
