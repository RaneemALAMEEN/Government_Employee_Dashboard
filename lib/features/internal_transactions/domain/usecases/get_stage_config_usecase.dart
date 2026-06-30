import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/dynamic_form_entity.dart';
import '../repositories/internal_transactions_repository.dart';

class GetStageConfigUseCase {
  final InternalTransactionsRepository repository;

  GetStageConfigUseCase(this.repository);

  Future<Either<Failure, DynamicFormEntity>> call({
    required int processId,
  }) {
    return repository.getStageConfig(processId: processId);
  }
}