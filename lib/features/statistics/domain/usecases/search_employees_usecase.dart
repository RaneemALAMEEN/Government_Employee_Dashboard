import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/employee_search_result_entity.dart';
import '../repositories/statistics_repository.dart';

class SearchEmployeesUseCase {
  final StatisticsRepository repository;

  SearchEmployeesUseCase(this.repository);

  Future<Either<Failure, EmployeeSearchResultEntity>> call({
    String? query,
    String? cursor,
    int limit = 6,
  }) {
    return repository.searchEmployees(
      query: query,
      cursor: cursor,
      limit: limit,
    );
  }
}
