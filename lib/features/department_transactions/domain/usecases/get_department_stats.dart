import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/department_transactions_repository.dart';

class GetDepartmentStats {
  final DepartmentTransactionsRepository repository;

  GetDepartmentStats(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({required String departmentIds}) async {
    final results = await Future.wait([
      repository.getCompletedStatsLastMonth(departmentIds: departmentIds),
      repository.getRejectedStatsLastMonth(departmentIds: departmentIds),
      repository.getActiveStats(departmentIds: departmentIds),
    ]);

    final completedResult = results[0];
    final rejectedResult = results[1];
    final activeResult = results[2];

    if (completedResult.isLeft()) return completedResult;
    if (rejectedResult.isLeft()) return rejectedResult;
    if (activeResult.isLeft()) return activeResult;

    final completedData = completedResult.getOrElse(() => {});
    final rejectedData = rejectedResult.getOrElse(() => {});
    final activeData = activeResult.getOrElse(() => {});

    return Right({
      'completed_count': completedData['count'] ?? 0,
      'rejected_count': rejectedData['count'] ?? 0,
      'active_count': activeData['count'] ?? 0,
      'in_progress_count': activeData['in_progress_count'] ?? 0,
      'pending_pickup_count': activeData['pending_pickup_count'] ?? 0,
    });
  }
}
