import '../entities/department_transaction_entity.dart';
import '../repositories/department_transactions_repository.dart';

class GetDepartmentTransactions {
  final DepartmentTransactionsRepository repository;

  const GetDepartmentTransactions(this.repository);

  Future<List<DepartmentTransactionEntity>> call() async {
    return await repository.getDepartmentTransactions();
  }
}
