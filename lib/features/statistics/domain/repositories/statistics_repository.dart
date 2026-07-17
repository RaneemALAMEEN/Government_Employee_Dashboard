import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/statistics_employee_entity.dart';
import '../entities/statistics_process_entity.dart';

abstract class StatisticsRepository {
  Future<Either<Failure, List<StatisticsEmployeeEntity>>>
      getEmployeesByDepartments({required List<int> departmentIds});

  Future<Either<Failure, List<StatisticsProcessEntity>>>
      getProcessDefinitionStats({
    required List<int> departmentIds,
    String? fromDate,
    String? toDate,
  });
}
