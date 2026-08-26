import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/employee_search_result_entity.dart';
import '../entities/process_search_result_entity.dart';
import '../entities/statistics_employee_details_entity.dart';
import '../entities/statistics_employee_entity.dart';
import '../entities/statistics_paginated_result.dart';
import '../entities/statistics_process_entity.dart';

abstract class StatisticsRepository {
  Future<Either<Failure, StatisticsEmployeeDetailsEntity>> getEmployeeDetails({
    required int employeeId,
  });

  Future<Either<Failure, EmployeeSearchResultEntity>> searchEmployees({
    String? query,
    String? cursor,
    int limit = 6,
  });

  Future<Either<Failure, ProcessSearchResultEntity>> searchProcessDefinitions({
    required int organizationId,
    String? query,
    String? cursor,
    int limit = 6,
    int? typeTransId,
    bool? isComplaint,
  });

  Future<Either<Failure, StatisticsPaginatedResult<StatisticsEmployeeEntity>>>
      getEmployeesByDepartments({
    required List<int> departmentIds,
    int limit = 6,
    String? cursor,
  });

  Future<Either<Failure, StatisticsPaginatedResult<StatisticsProcessEntity>>>
      getProcessDefinitionStats({
    required List<int> departmentIds,
    int limit = 6,
    String? cursor,
    String? fromDate,
    String? toDate,
  });
}
