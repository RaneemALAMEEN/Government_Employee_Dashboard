import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/process_definitions_response_entity.dart';
import '../repositories/directorate_process_repository.dart';

class GetComplaintProcessDefinitions {
  final DirectorateProcessRepository repository;

  const GetComplaintProcessDefinitions(this.repository);

  Future<Either<Failure, ProcessDefinitionsResponseEntity>> call({
    int page = 1,
    int limit = 20,
  }) =>
      repository.getComplaintProcessDefinitions(page: page, limit: limit);
}
