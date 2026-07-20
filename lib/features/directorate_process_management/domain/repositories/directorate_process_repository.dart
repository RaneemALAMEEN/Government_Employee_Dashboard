import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/process_definitions_response_entity.dart';
import '../entities/transaction_type_entity.dart';

abstract class DirectorateProcessRepository {
  Future<Either<Failure, List<TransactionTypeEntity>>> getTransactionTypes();

  Future<Either<Failure, ProcessDefinitionsResponseEntity>>
      getProcessDefinitions({
    required int typeId,
    int page = 1,
    int limit = 20,
  });
}
