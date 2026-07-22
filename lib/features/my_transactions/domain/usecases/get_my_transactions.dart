import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/my_transactions_paginated_result.dart';
import '../repositories/my_transactions_repository.dart';

class GetMyTransactions {
  final MyTransactionsRepository repository;

  GetMyTransactions(this.repository);

  Future<Either<Failure, MyTransactionsPaginatedResult>> call({
    required String status,
    String? cursor,
    int limit = 6,
  }) {
    return repository.getMyTransactions(
      status: status,
      cursor: cursor,
      limit: limit,
    );
  }
}
