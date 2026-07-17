import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/statistics_process_entity.dart';
import '../repositories/statistics_repository.dart';

class GetProcessDefinitionStats {
  final StatisticsRepository repository;

  GetProcessDefinitionStats(this.repository);

  Future<Either<Failure, List<StatisticsProcessEntity>>> call({
    required List<int> departmentIds,
    String? fromDate,
    String? toDate,
  }) {
    return repository.getProcessDefinitionStats(
      departmentIds: departmentIds,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}
