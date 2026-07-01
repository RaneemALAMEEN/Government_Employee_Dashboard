import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/internal_category_entity.dart';
import '../repositories/internal_transactions_repository.dart';

class GetInternalCategoriesUseCase {
  final InternalTransactionsRepository repository;

  GetInternalCategoriesUseCase(this.repository);

  Future<Either<Failure, List<InternalCategoryEntity>>> call() {
    return repository.getCategories();
  }
}