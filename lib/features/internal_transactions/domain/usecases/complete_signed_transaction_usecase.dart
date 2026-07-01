import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/internal_transactions_repository.dart';

class CompleteSignedTransactionUseCase {
  final InternalTransactionsRepository repository;

  CompleteSignedTransactionUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    required int transactionId,
    required Map<String, dynamic> payload,
  }) {
    return repository.completeSignedTransaction(
      transactionId: transactionId,
      payload: payload,
    );
  }
}