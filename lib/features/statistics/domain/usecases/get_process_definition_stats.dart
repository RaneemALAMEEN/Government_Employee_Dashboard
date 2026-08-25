import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/statistics_process_entity.dart';
import '../entities/statistics_paginated_result.dart';
import '../repositories/statistics_repository.dart';

class GetProcessDefinitionStats {
  final StatisticsRepository repository;

  GetProcessDefinitionStats(this.repository);

  Future<Either<Failure, StatisticsPaginatedResult<StatisticsProcessEntity>>>
      call({
    required List<int> departmentIds,
    required int limit,
    String? cursor,
    String? fromDate,
    String? toDate,
  }) {
    return repository.getProcessDefinitionStats(
      departmentIds: departmentIds,
      limit: limit,
      cursor: cursor,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}
