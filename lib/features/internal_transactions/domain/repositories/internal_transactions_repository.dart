import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/dynamic_form_entity.dart';
import '../entities/internal_category_entity.dart';
import '../entities/internal_processes_page_entity.dart';
import '../entities/internal_transaction_counts_entity.dart';
import '../entities/internal_transactions_page_entity.dart';

abstract class InternalTransactionsRepository {
  Future<Either<Failure, List<InternalCategoryEntity>>> getCategories();

  Future<Either<Failure, InternalProcessesPageEntity>> getProcessesByCategory({
    required int categoryId,
    required int page,
    required int limit,
  });

  Future<Either<Failure, InternalTransactionCountsEntity>>
      getMyTransactionCounts();

  Future<Either<Failure, InternalTransactionsPageEntity>> getMyTransactions({
    required int page,
    required int limit,
    String? status,
  });

  Future<Either<Failure, DynamicFormEntity>> getStageConfig({
    required int processId,
  });

  Future<Either<Failure, Map<String, dynamic>>> uploadTransactionFile({
    required String filePath,
    required int typeDocId,
    required String key,
  });

  Future<Either<Failure, Map<String, dynamic>>> createSigningChallenge({
    required int processId,
    required String pin,
  });

  Future<Either<Failure, Map<String, dynamic>>> completeSignedTransaction({
    required int transactionId,
    required Map<String, dynamic> payload,
  });
}