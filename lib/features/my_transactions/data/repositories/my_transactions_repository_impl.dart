import 'package:dartz/dartz.dart';
import 'package:government_employee_dashboard/core/errors/failures.dart';

import '../../domain/entities/my_transaction_entity.dart';
import '../../domain/repositories/my_transactions_repository.dart';
import '../datasources/my_transactions_remote_data_source.dart';
import '../models/my_transaction_model.dart';

class MyTransactionsRepositoryImpl implements MyTransactionsRepository {
  final MyTransactionsRemoteDataSource remoteDataSource;

  MyTransactionsRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<MyTransactionEntity>> getMyTransactions() async {
    final results = await Future.wait([
      remoteDataSource.getPendingPickupTasks(limit: 50),
      remoteDataSource.getInProgressTasks(limit: 50),
      remoteDataSource.getTasks(status: 'completed', limit: 50),
      remoteDataSource.getTasks(status: 'rejected', limit: 50),
    ]);

    final List<MyTransactionEntity> mergedList = [];
    final Set<String> numbers = {};

    for (final result in results) {
      result.fold(
        (failure) {
          throw Exception(failure.message);
        },
        (data) {
          if (data is Map && data['data'] != null && data['data']['items'] is List) {
            final itemsList = data['data']['items'] as List;
            for (final item in itemsList) {
              if (item is Map) {
                // Cast to Map<String, dynamic> safely
                final mapItem = Map<String, dynamic>.from(item);
                final model = MyTransactionModel.fromJson(mapItem);
                if (!numbers.contains(model.number)) {
                  numbers.add(model.number);
                  mergedList.add(model);
                }
              }
            }
          }
        },
      );
    }

    return mergedList;
  }
  @override
  Future<Either<Failure, Map<String, dynamic>>> getTaskDetails({required String taskId}) async {
    final result = await remoteDataSource.getTaskDetails(taskId: taskId);
    return result.map((r) => r as Map<String, dynamic>);
  }

  @override
  Future<Either<Failure, dynamic>> pickupTask({required String taskId}) async {
    return await remoteDataSource.pickupTask(taskId: taskId);
  }

  @override
  Future<Either<Failure, dynamic>> releaseTask({required String taskId}) async {
    return await remoteDataSource.releaseTask(taskId: taskId);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createSigningChallenge({
    required String taskId,
    required String pin,
    required String decision,
    bool isSubmitDocuments = false,
  }) async {
    final result = await remoteDataSource.createSigningChallenge(
      taskId: taskId,
      pin: pin,
      decision: decision,
      isSubmitDocuments: isSubmitDocuments,
    );
    return result.map((r) => r as Map<String, dynamic>);
  }

  @override
  Future<Either<Failure, dynamic>> completeTask({
    required String taskId,
    required Map<String, dynamic> payload,
    bool isSubmitDocuments = false,
  }) async {
    return await remoteDataSource.completeTask(
      taskId: taskId,
      payload: payload,
      isSubmitDocuments: isSubmitDocuments,
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> uploadTransactionFile({
    required String filePath,
    required int typeDocId,
    required String key,
  }) async {
    final result = await remoteDataSource.uploadTransactionFile(
      filePath: filePath,
      typeDocId: typeDocId,
      key: key,
    );
    return result.map((r) {
      if (r is Map) {
         return r['data'] as Map<String, dynamic>? ?? Map<String, dynamic>.from(r);
      }
      return <String, dynamic>{};
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDocumentTemplate({
    required int templateId,
  }) async {
    final result = await remoteDataSource.getDocumentTemplate(templateId: templateId);
    return result.map((r) => r as Map<String, dynamic>);
  }
}
