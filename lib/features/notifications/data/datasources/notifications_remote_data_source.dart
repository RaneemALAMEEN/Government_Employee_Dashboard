import '../../../../core/enums/api_method.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/api_const.dart';
import '../../../../core/services/api_service.dart';
import '../models/notifications_response_model.dart';

class NotificationsRemoteDataSource {
  final ApiService apiService;

  const NotificationsRemoteDataSource(this.apiService);

  static const _endPoints = EndPoints();

  Future<NotificationsResponseModel> getMyNotifications({
    required int limit,
    String? cursor,
    bool unreadOnly = false,
  }) async {
    final query = <String, dynamic>{'limit': limit};
    if (cursor != null && cursor.isNotEmpty) query['cursor'] = cursor;
    if (unreadOnly) query['unread'] = true;

    final result = await apiService.makeRequest(
      method: ApiMethod.get,
      endPoint: _endPoints.myNotifications,
      queryParameters: query,
    );
    return result.fold(
      (failure) => throw ServerException(failure.message),
      (response) {
        if (response is! Map) {
          throw const ServerException('استجابة الإشعارات غير صالحة');
        }
        return NotificationsResponseModel.fromJson(
          Map<String, dynamic>.from(response),
          requestedLimit: limit,
        );
      },
    );
  }
}
