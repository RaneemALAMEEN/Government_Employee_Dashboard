import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/internal_transaction_counts_entity.dart';
import '../repositories/internal_transactions_repository.dart';

class GetMyTransactionCountsUseCase {
  final InternalTransactionsRepository repository;

  GetMyTransactionCountsUseCase(this.repository);

  Future<Either<Failure, InternalTransactionCountsEntity>> call() {
    return repository.getMyTransactionCounts();
  }
}