import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/internal_transactions_page_entity.dart';
import '../repositories/internal_transactions_repository.dart';

class GetMyTransactionsUseCase {
  final InternalTransactionsRepository repository;

  GetMyTransactionsUseCase(this.repository);

  Future<Either<Failure, InternalTransactionsPageEntity>> call({
    required int page,
    required int limit,
    String? status,
  }) {
    return repository.getMyTransactions(
      page: page,
      limit: limit,
      status: status,
    );
  }
}