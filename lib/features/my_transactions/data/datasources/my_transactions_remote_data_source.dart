import 'package:dartz/dartz.dart';

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
}
