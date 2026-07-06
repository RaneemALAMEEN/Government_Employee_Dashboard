import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/internal_transaction_first_stage_entity.dart';
import '../repositories/internal_transactions_repository.dart';

class GetInternalTransactionFirstStageUseCase {
  final InternalTransactionsRepository repository;

  GetInternalTransactionFirstStageUseCase(this.repository);

  Future<Either<Failure, InternalTransactionFirstStageEntity>> call({
    required int transactionId,
  }) {
    return repository.getFirstStageTransaction(transactionId: transactionId);
  }
}
