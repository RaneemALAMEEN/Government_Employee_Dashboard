import 'package:flutter/foundation.dart';

import '../../../../core/enums/api_method.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/api_const.dart';
import '../../../../core/services/api_service.dart';
import '../models/self_card_model.dart';
import '../models/self_card_search_item_model.dart';
import '../models/training_recommendation_model.dart';

class SelfCardsRemoteDataSource {
  final ApiService apiService;

  SelfCardsRemoteDataSource(this.apiService);

  static const _endPoints = EndPoints();

  Future<List<SelfCardSearchItemModel>> searchSelfCards({
    String? query,
    String? cursor,
    int limit = 20,
    bool activeOnly = true,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      'active_only': activeOnly,
    };

    final cleanQuery = query?.trim();
    if (cleanQuery != null && cleanQuery.isNotEmpty) {
      queryParams['q'] = cleanQuery;
      queryParams['search'] = cleanQuery;
    }

    if (cursor != null && cursor.isNotEmpty) {
      queryParams['cursor'] = cursor;
    }

    final result = await apiService.makeRequest(
      method: ApiMethod.get,
      endPoint: _endPoints.selfCardsSearch,
      queryParameters: queryParams,
    );

    return result.fold(
      (failure) => throw ServerException(failure.message),
      (response) {
        debugPrint('[SelfCardsRemoteDataSource] Search response received');
        List<dynamic> itemsList = [];

        if (response is List) {
          itemsList = response;
        } else if (response is Map) {
          final data = response['data'];
          if (data is List) {
            itemsList = data;
          } else if (data is Map) {
            final items = data['items'] ?? data['self_cards'] ?? data['cards'] ?? data['rows'];
            if (items is List) {
              itemsList = items;
            }
          }
        }

        return itemsList
            .whereType<Map>()
            .map((item) => SelfCardSearchItemModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      },
    );
  }

  Future<SelfCardModel> getSelfCardDetails(int id) async {
    final result = await apiService.makeRequest(
      method: ApiMethod.get,
      endPoint: _endPoints.selfCardDetails(id),
    );

    return result.fold(
      (failure) => throw ServerException(failure.message),
      (response) {
        debugPrint('[SelfCardsRemoteDataSource] Details response received for ID: $id');
        Map<String, dynamic>? dataMap;

        if (response is Map) {
          final data = response['data'];
          if (data is Map) {
            dataMap = Map<String, dynamic>.from(data);
          } else {
            dataMap = Map<String, dynamic>.from(response);
          }
        }

        if (dataMap == null) {
          throw const ServerException('بيانات البطاقة الذاتية غير صالحة أو فارغة');
        }

        return SelfCardModel.fromJson(dataMap);
      },
    );
  }

  Future<SelfCardModel?> getSelfCardByEmployeeId(int employeeId) async {
    final result = await apiService.makeRequest(
      method: ApiMethod.get,
      endPoint: _endPoints.employeeSelfCard(employeeId),
    );

    return result.fold(
      (failure) {
        if (failure.statusCode == 404 ||
            failure.message.contains('تعذر العثور') ||
            failure.message.contains('غير موجود')) {
          debugPrint(
            '[SelfCardsRemoteDataSource] No self card found for employee ID: $employeeId (404)',
          );
          return null;
        }
        throw ServerException(failure.message);
      },
      (response) {
        debugPrint(
          '[SelfCardsRemoteDataSource] Employee self-card response received for employee ID: $employeeId',
        );
        Map<String, dynamic>? dataMap;

        if (response is Map) {
          final data = response['data'];
          if (data is Map) {
            dataMap = Map<String, dynamic>.from(data);
          } else if (response['success'] == true && response['id'] != null) {
            dataMap = Map<String, dynamic>.from(response);
          }
        }

        if (dataMap == null) {
          return null;
        }

        return SelfCardModel.fromJson(dataMap);
      },
    );
  }

  Future<TrainingRecommendationResultModel> recommendByTraining({
    required String title,
    int limit = 20,
    String? publicEntity,
  }) async {
    final body = <String, dynamic>{
      'title': title.trim(),
      'limit': limit,
    };

    final cleanEntity = publicEntity?.trim();
    if (cleanEntity != null && cleanEntity.isNotEmpty) {
      body['public_entity'] = cleanEntity;
    }

    final result = await apiService.makeRequest(
      method: ApiMethod.post,
      endPoint: _endPoints.recommendSelfCardsByTraining,
      body: body,
    );

    return result.fold(
      (failure) => throw ServerException(failure.message),
      (response) {
        debugPrint(
          '[SelfCardsRemoteDataSource] Recommend by training response received',
        );

        if (response is Map) {
          return TrainingRecommendationResultModel.fromJson(
            Map<String, dynamic>.from(response),
          );
        }

        throw const ServerException('استجابة غير صالحة من خادم الترشيح');
      },
    );
  }
}

