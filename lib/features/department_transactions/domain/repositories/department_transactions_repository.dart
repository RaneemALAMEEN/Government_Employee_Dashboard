import '../entities/department_transaction_entity.dart';

abstract class DepartmentTransactionsRepository {
  Future<List<DepartmentTransactionEntity>> getDepartmentTransactions();
}
