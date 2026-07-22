import 'package:dartz/dartz.dart';
import 'package:government_employee_dashboard/core/errors/failures.dart';

import '../../domain/entities/my_transaction_entity.dart';
import '../../domain/entities/my_transactions_paginated_result.dart';
import '../../domain/repositories/my_transactions_repository.dart';
import '../datasources/my_transactions_remote_data_source.dart';
import '../models/my_transaction_model.dart';

class MyTransactionsRepositoryImpl implements MyTransactionsRepository {
  final MyTransactionsRemoteDataSource remoteDataSource;

  MyTransactionsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, MyTransactionsPaginatedResult>> getMyTransactions({
    required String status,
    String? cursor,
    int limit = 6,
  }) async {
    final result = await remoteDataSource.getTasks(
      status: status,
      cursor: cursor,
      limit: limit,
    );

    return result.fold(
      (failure) => Left(failure),
      (data) {
        final List<MyTransactionEntity> items = [];
        String? nextCursor;
        bool hasNext = false;
        int totalCount = 0;

        if (data is Map && data['data'] != null) {
          final dataMap = data['data'];

          // Parse items
          if (dataMap['items'] is List) {
            final itemsList = dataMap['items'] as List;
            for (final item in itemsList) {
              if (item is Map) {
                final mapItem = Map<String, dynamic>.from(item);
                items.add(MyTransactionModel.fromJson(mapItem));
              }
            }
          }

          // Parse pagination
          if (dataMap['pagination'] is Map) {
            final pagination = dataMap['pagination'];
            nextCursor = pagination['next_cursor'] as String?;
            hasNext = pagination['has_next'] as bool? ?? false;

            final totalRaw = pagination['total'] ?? pagination['total_items'];
            if (totalRaw != null) {
              totalCount = int.tryParse(totalRaw.toString()) ?? 0;
            }
          }
        }
        return Right(MyTransactionsPaginatedResult(
          items: items,
          nextCursor: nextCursor,
          hasNext: hasNext,
          totalCount: totalCount,
        ));
      },
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTaskDetails(
      {required String taskId}) async {
    final result = await remoteDataSource.getTaskDetails(taskId: taskId);
    return result.map((r) => r as Map<String, dynamic>);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTransactionCertificate(
      {required String taskId}) async {
    final result =
        await remoteDataSource.getTransactionCertificate(taskId: taskId);
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
        return r['data'] as Map<String, dynamic>? ??
            Map<String, dynamic>.from(r);
      }
      return <String, dynamic>{};
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDocumentTemplate({
    required int templateId,
  }) async {
    final result =
        await remoteDataSource.getDocumentTemplate(templateId: templateId);
    return result.map((r) => r as Map<String, dynamic>);
  }
}
