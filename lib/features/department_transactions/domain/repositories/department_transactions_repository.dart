import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/department_transaction_entity.dart';

abstract class DepartmentTransactionsRepository {
  Future<Either<Failure, Map<String, dynamic>>> getCompletedTransactions({
    String? departmentIds,
    String? fromDate,
    String? toDate,
    int page = 1,
    int limit = 10,
  });

  Future<Either<Failure, Map<String, dynamic>>> getRejectedTransactions({
    String? departmentIds,
    String? fromDate,
    String? toDate,
    int page = 1,
    int limit = 10,
  });

  Future<Either<Failure, Map<String, dynamic>>> getTransactionCertificate(String transactionId);
}
