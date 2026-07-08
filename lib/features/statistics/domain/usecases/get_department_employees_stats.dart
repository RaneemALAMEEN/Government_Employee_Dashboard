import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/statistics_employee_entity.dart';
import '../repositories/statistics_repository.dart';

class GetDepartmentEmployeesStats {
  final StatisticsRepository repository;

  GetDepartmentEmployeesStats(this.repository);

  Future<Either<Failure, List<StatisticsEmployeeEntity>>> call(
      {required List<int> departmentIds}) {
    return repository.getEmployeesByDepartments(departmentIds: departmentIds);
  }
}
