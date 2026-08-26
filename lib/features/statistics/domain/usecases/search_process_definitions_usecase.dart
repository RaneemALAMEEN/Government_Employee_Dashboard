import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/process_search_result_entity.dart';
import '../repositories/statistics_repository.dart';

class SearchProcessDefinitionsUseCase {
  final StatisticsRepository repository;

  SearchProcessDefinitionsUseCase(this.repository);

  Future<Either<Failure, ProcessSearchResultEntity>> call({
    required int organizationId,
    String? query,
    String? cursor,
    int limit = 6,
    int? typeTransId,
    bool? isComplaint,
  }) {
    return repository.searchProcessDefinitions(
      organizationId: organizationId,
      query: query,
      cursor: cursor,
      limit: limit,
      typeTransId: typeTransId,
      isComplaint: isComplaint,
    );
  }
}
