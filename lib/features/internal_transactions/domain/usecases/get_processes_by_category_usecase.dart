import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/internal_processes_page_entity.dart';
import '../repositories/internal_transactions_repository.dart';

class GetProcessesByCategoryUseCase {
  final InternalTransactionsRepository repository;

  GetProcessesByCategoryUseCase(this.repository);

  Future<Either<Failure, InternalProcessesPageEntity>> call({
    required int categoryId,
    required int page,
    required int limit,
  }) {
    return repository.getProcessesByCategory(
      categoryId: categoryId,
      page: page,
      limit: limit,
    );
  }
}