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
    String? searchQuery,
    int limit = 6,
  }) async {
    // إذا كان هناك نص بحث، نستخدم search APIs
    final hasSearch = searchQuery != null && searchQuery.trim().isNotEmpty;

    if (status == 'منجزة') {
      if (hasSearch && departmentIds != null) {
        return await repository.searchCompletedTransactions(
          departmentIds: departmentIds,
          query: searchQuery,
          fromDate: fromDate,
          toDate: toDate,
          cursor: cursor,
          limit: limit,
        );
      }
      return await repository.getCompletedTransactions(
        departmentIds: departmentIds,
        fromDate: fromDate,
        toDate: toDate,
        cursor: cursor,
        limit: limit,
      );
    } else if (status == 'مرفوضة') {
      if (hasSearch && departmentIds != null) {
        return await repository.searchRejectedTransactions(
          departmentIds: departmentIds,
          query: searchQuery,
          fromDate: fromDate,
          toDate: toDate,
          cursor: cursor,
          limit: limit,
        );
      }
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
