import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/statistics_employee_entity.dart';
import '../entities/statistics_employee_details_entity.dart';
import '../entities/statistics_process_entity.dart';
import '../entities/statistics_paginated_result.dart';

abstract class StatisticsRepository {
  Future<Either<Failure, StatisticsEmployeeDetailsEntity>> getEmployeeDetails({
    required int employeeId,
  });

  Future<Either<Failure, StatisticsPaginatedResult<StatisticsEmployeeEntity>>>
      getEmployeesByDepartments({
    required List<int> departmentIds,
    required int limit,
    String? cursor,
  });

  Future<Either<Failure, StatisticsPaginatedResult<StatisticsProcessEntity>>>
      getProcessDefinitionStats({
    required List<int> departmentIds,
    required int limit,
    String? cursor,
    String? fromDate,
    String? toDate,
  });
}
