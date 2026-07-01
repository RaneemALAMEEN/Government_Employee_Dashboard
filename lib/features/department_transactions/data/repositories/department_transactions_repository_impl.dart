import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/department_transactions_repository.dart';
import '../datasources/department_transactions_remote_data_source.dart';
import '../models/department_transaction_model.dart';

class DepartmentTransactionsRepositoryImpl implements DepartmentTransactionsRepository {
  final DepartmentTransactionsRemoteDataSource remoteDataSource;

  const DepartmentTransactionsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCompletedTransactions({
    String? departmentIds,
    String? fromDate,
    String? toDate,
    int page = 1,
    int limit = 10,
  }) async {
    final result = await remoteDataSource.getCompletedTransactions(
      departmentIds: departmentIds,
      fromDate: fromDate,
      toDate: toDate,
      page: page,
      limit: limit,
    );

    return result.map((data) => _mapResponse(data));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getRejectedTransactions({
    String? departmentIds,
    String? fromDate,
    String? toDate,
    int page = 1,
    int limit = 10,
  }) async {
    final result = await remoteDataSource.getRejectedTransactions(
      departmentIds: departmentIds,
      fromDate: fromDate,
      toDate: toDate,
      page: page,
      limit: limit,
    );

    return result.map((data) => _mapResponse(data));
  }

  Map<String, dynamic> _mapResponse(dynamic data) {
    if (data is Map<String, dynamic> && data['data'] != null) {
      final itemsList = data['data']['items'] as List? ?? [];
      final transactions = itemsList
          .map((item) => DepartmentTransactionModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      final pagination = data['data']['pagination'] as Map<String, dynamic>? ?? {};

      return {
        'items': transactions,
        'pagination': pagination,
      };
    }
    return {
      'items': <DepartmentTransactionModel>[],
      'pagination': <String, dynamic>{},
    };
  }
}
