import 'package:flutter/foundation.dart';

import '../../../../core/enums/api_method.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/api_const.dart';
import '../../../../core/services/api_service.dart';
import '../models/process_definitions_response_model.dart';
import '../models/transaction_type_model.dart';

class DirectorateProcessRemoteDataSource {
  final ApiService apiService;
  const DirectorateProcessRemoteDataSource(this.apiService);

  static const _endPoints = EndPoints();

  Future<List<TransactionTypeModel>> getTransactionTypes() async {
    final result = await apiService.makeRequest(
      method: ApiMethod.get,
      endPoint: _endPoints.typeProcess,
    );
    return result.fold(
      (failure) => throw ServerException(failure.message),
      (response) {
        final body = response is Map ? response : const <String, dynamic>{};
        final data = body['data'];
        final items = data is List ? data : const [];
        return items
            .whereType<Map>()
            .map((item) => TransactionTypeModel.fromJson(
                  Map<String, dynamic>.from(item),
                ))
            .toList();
      },
    );
  }

  Future<ProcessDefinitionsResponseModel> getProcessDefinitions({
    required int typeId,
    required int page,
    required int limit,
  }) async {
    final result = await apiService.makeRequest(
      method: ApiMethod.get,
      endPoint: _endPoints.adminProcessDefinitionsByType(typeId),
      queryParameters: {'page': page, 'limit': limit},
    );
    return result.fold(
      (failure) => throw ServerException(failure.message),
      (response) {
        if (kDebugMode) {
          debugPrint('[DirectorateProcessManagement] Full admin response:');
          debugPrint(response.toString());
        }
        if (response is! Map) {
          throw const ServerException('استجابة القوالب غير صالحة');
        }
        return ProcessDefinitionsResponseModel.fromJson(
          Map<String, dynamic>.from(response),
          requestedPage: page,
          requestedLimit: limit,
        );
      },
    );
  }
}
