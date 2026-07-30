import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/department_transactions_repository.dart';

class GetDepartmentTransactions {
  final DepartmentTransactionsRepository repository;

  GetDepartmentTransactions(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    required String status,
    String? departmentIds,
    String? fromDate,
    String? toDate,
    String? cursor,
    int limit = 6,
  }) async {
    if (status == 'منجزة') {
      return await repository.getCompletedTransactions(
        departmentIds: departmentIds,
        fromDate: fromDate,
        toDate: toDate,
        cursor: cursor,
        limit: limit,
      );
    } else if (status == 'مرفوضة') {
      return await repository.getRejectedTransactions(
        departmentIds: departmentIds,
        fromDate: fromDate,
        toDate: toDate,
        cursor: cursor,
        limit: limit,
      );
    } else {
      return Left(ServerFailure('حالة غير صالحة'));
    }
  }
}
