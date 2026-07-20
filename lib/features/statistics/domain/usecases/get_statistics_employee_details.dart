import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/statistics_employee_details_entity.dart';
import '../repositories/statistics_repository.dart';

class GetStatisticsEmployeeDetails {
  final StatisticsRepository repository;

  const GetStatisticsEmployeeDetails(this.repository);

  Future<Either<Failure, StatisticsEmployeeDetailsEntity>> call({
    required int employeeId,
  }) {
    return repository.getEmployeeDetails(employeeId: employeeId);
  }
}
