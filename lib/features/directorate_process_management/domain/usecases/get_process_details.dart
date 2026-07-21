import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/process_details_entity.dart';
import '../repositories/directorate_process_repository.dart';

class GetProcessDetails {
  final DirectorateProcessRepository repository;

  const GetProcessDetails(this.repository);

  Future<Either<Failure, ProcessDetailsEntity>> call({
    required int processId,
  }) =>
      repository.getProcessDetails(processId: processId);
}
