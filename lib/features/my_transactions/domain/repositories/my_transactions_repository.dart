import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/my_transaction_entity.dart';
import '../entities/my_transactions_paginated_result.dart';

abstract class MyTransactionsRepository {
  Future<Either<Failure, MyTransactionsPaginatedResult>> getMyTransactions({
    required String status,
    String? cursor,
    int limit = 6,
  });
  
  Future<Either<Failure, Map<String, dynamic>>> getTaskDetails({required String taskId});
  
  Future<Either<Failure, dynamic>> pickupTask({required String taskId});
  
  Future<Either<Failure, dynamic>> releaseTask({required String taskId});
  
  Future<Either<Failure, Map<String, dynamic>>> createSigningChallenge({
    required String taskId,
    required String pin,
    required String decision,
    bool isSubmitDocuments = false,
  });
  
  Future<Either<Failure, dynamic>> completeTask({
    required String taskId,
    required Map<String, dynamic> payload,
    bool isSubmitDocuments = false,
  });

  Future<Either<Failure, Map<String, dynamic>>> uploadTransactionFile({
    required String filePath,
    required int typeDocId,
    required String key,
  });

  Future<Either<Failure, Map<String, dynamic>>> getDocumentTemplate({
    required int templateId,
  });
}
