import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/statistics_employee_entity.dart';
import '../entities/statistics_paginated_result.dart';
import '../repositories/statistics_repository.dart';

class GetDepartmentEmployeesStats {
  final StatisticsRepository repository;

  GetDepartmentEmployeesStats(this.repository);

  Future<Either<Failure, StatisticsPaginatedResult<StatisticsEmployeeEntity>>>
      call({
    required List<int> departmentIds,
    required int limit,
    String? cursor,
  }) {
    return repository.getEmployeesByDepartments(
      departmentIds: departmentIds,
      limit: limit,
      cursor: cursor,
    );
  }
}
